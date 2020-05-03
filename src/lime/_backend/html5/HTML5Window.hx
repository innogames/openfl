package lime._backend.html5;

import haxe.Timer;
import js.html.CanvasElement;
import js.html.Element;
import js.html.FocusEvent;
import js.html.InputElement;
import js.html.IFrameElement;
import js.html.InputEvent;
import js.html.MouseEvent;
import js.html.TouchEvent;
import js.html.ClipboardEvent;
import js.html.WheelEvent;
import js.Browser;
import lime.app.Application;
import lime.system.Clipboard;
import lime.ui.Gamepad;
import lime.ui.Joystick;
import lime.ui.Touch;
import lime.ui.Window;

@:access(lime.app.Application)
@:access(lime.ui.Gamepad)
@:access(lime.ui.Joystick)
@:access(lime.ui.Window)
class HTML5Window {
	private static var dummyCharacter = String.fromCharCode(127);
	private static var textInput:InputElement;
	private static var windowID:Int = 0;
	private static var scrollLineHeight = getScrollLineHeight();

	public var canvas:CanvasElement;
	public var element:Element;

	private var cacheElementHeight:Float;
	private var cacheElementWidth:Float;
	private var cacheMouseX:Float;
	private var cacheMouseY:Float;
	private var currentTouches = new Map<Int, Touch>();
	private var enableTextEvents:Bool;
	private var isFullscreen:Bool;
	private var parent:Window;
	private var primaryTouch:Touch;
	private var requestedFullscreen:Bool;
	private var resizeElement:Bool;
	private var scale = 1.0;
	private var setHeight:Int;
	private var setWidth:Int;
	private var unusedTouchesPool = new List<Touch>();

	public function new(parent:Window) {
		this.parent = parent;

		if (parent.config != null && Reflect.hasField(parent.config, "element")) {
			element = parent.config.element;
		}

		updateScale();

		cacheMouseX = 0;
		cacheMouseY = 0;
	}

	public function create(application:Application):Void {
		setWidth = parent.width;
		setHeight = parent.height;

		parent.id = windowID++;

		if (Std.is(element, CanvasElement)) {
			canvas = cast element;
		} else {
			canvas = cast Browser.document.createElement("canvas");
		}

		if (canvas != null) {
			var style = canvas.style;
			style.setProperty("-webkit-transform", "translateZ(0)", null);
			style.setProperty("transform", "translateZ(0)", null);
		}

		if (parent.width == 0 && parent.height == 0) {
			if (element != null) {
				parent.width = element.clientWidth;
				parent.height = element.clientHeight;
			} else {
				parent.width = Browser.window.innerWidth;
				parent.height = Browser.window.innerHeight;
			}

			cacheElementWidth = parent.width;
			cacheElementHeight = parent.height;

			resizeElement = true;
		}

		if (canvas != null) {
			canvas.width = Math.round(parent.width * scale);
			canvas.height = Math.round(parent.height * scale);

			canvas.style.width = parent.width + "px";
			canvas.style.height = parent.height + "px";
		}

		updateSize();

		if (element != null) {
			if (canvas != null) {
				if (element != cast canvas) {
					element.appendChild(canvas);
				}
			}

			var events = ["mousedown", "mouseenter", "mouseleave", "mousemove", "mouseup", "wheel"];

			for (event in events) {
				element.addEventListener(event, handleMouseEvent, true);
			}

			// Disable image drag on Firefox
			Browser.document.addEventListener("dragstart", function(e) {
				if (e.target.nodeName.toLowerCase() == "img") {
					e.preventDefault();
					return false;
				}
				return true;
			}, false);

			element.addEventListener("contextmenu", handleContextMenuEvent, true);

			element.addEventListener("touchstart", handleTouchEvent, true);
			element.addEventListener("touchmove", handleTouchEvent, true);
			element.addEventListener("touchend", handleTouchEvent, true);
			element.addEventListener("touchcancel", handleTouchEvent, true);

			element.addEventListener("gamepadconnected", handleGamepadEvent, true);
			element.addEventListener("gamepaddisconnected", handleGamepadEvent, true);
		}
	}

	public function getEnableTextEvents():Bool {
		return enableTextEvents;
	}

	private function handleContextMenuEvent(event:MouseEvent):Void {
		if (!parent.enableContextMenuEvents) {
			event.preventDefault();
		}
	}

	private function handleCopyEvent(event:ClipboardEvent):Void {
		event.preventDefault();

		if (settingSystemClipboard) {
			event.clipboardData.setData("text/plain", Clipboard.text);
		} else {
			parent.onTextCopy.dispatch(function(string) {
				event.clipboardData.setData("text/plain", string);
				Clipboard.setText(string, false);
			});
		}
	}

	private function handleCutEvent(event:ClipboardEvent):Void {
		event.preventDefault();

		parent.onTextCut.dispatch(function(string) {
			event.clipboardData.setData("text/plain", string);
			Clipboard.setText(string, false);
		});
	}

	private function handleFocusEvent(event:FocusEvent):Void {
		if (enableTextEvents) {
			Timer.delay(function() {
				textInput.focus();
			}, 20);
		}
	}

	private function handleFullscreenEvent(event:Dynamic):Void {
		var fullscreenElement = untyped (document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
			|| document.msFullscreenElement);

		if (fullscreenElement != null) {
			isFullscreen = true;
			parent.__fullscreen = true;

			if (requestedFullscreen) {
				requestedFullscreen = false;
				parent.onFullscreen.dispatch();
			}
		} else {
			isFullscreen = false;
			parent.__fullscreen = false;

			parent.onRestore.dispatch();

			var changeEvents = [
				"fullscreenchange",
				"mozfullscreenchange",
				"webkitfullscreenchange",
				"MSFullscreenChange"
			];
			var errorEvents = [
				"fullscreenerror",
				"mozfullscreenerror",
				"webkitfullscreenerror",
				"MSFullscreenError"
			];

			for (i in 0...changeEvents.length) {
				Browser.document.removeEventListener(changeEvents[i], handleFullscreenEvent, false);
				Browser.document.removeEventListener(errorEvents[i], handleFullscreenEvent, false);
			}
		}
	}

	private function handleGamepadEvent(event:Dynamic):Void {
		switch (event.type) {
			case "gamepadconnected":
				Joystick.__connect(event.gamepad.index);

				if (event.gamepad.mapping == "standard") {
					Gamepad.__connect(event.gamepad.index);
				}

			case "gamepaddisconnected":
				Joystick.__disconnect(event.gamepad.index);
				Gamepad.__disconnect(event.gamepad.index);

			default:
		}
	}

	private function handleInputEvent(event:InputEvent):Void {
		// In order to ensure that the browser will fire clipboard events, we always need to have something selected.
		// Therefore, `value` cannot be "".

		if (textInput.value != dummyCharacter) {
			var value = normalizeInputNewlines(StringTools.replace(textInput.value, dummyCharacter, ""));

			if (value.length > 0) {
				parent.onTextInput.dispatch(value);
			}

			textInput.value = dummyCharacter;
		}
	}

	private function handleMouseEvent(event:MouseEvent):Void {
		var x = 0.0;
		var y = 0.0;

		if (event.type != "wheel") {
			if (element != null) {
				if (canvas != null) {
					var rect = canvas.getBoundingClientRect();
					x = (event.clientX - rect.left) * (parent.width / rect.width);
					y = (event.clientY - rect.top) * (parent.height / rect.height);
				} else {
					var rect = element.getBoundingClientRect();
					x = (event.clientX - rect.left) * (parent.width / rect.width);
					y = (event.clientY - rect.top) * (parent.height / rect.height);
				}
			} else {
				x = event.clientX;
				y = event.clientY;
			}

			switch (event.type) {
				case "mousedown":
					if (event.currentTarget == element) {
						// Release outside browser window
						Browser.window.addEventListener("mouseup", handleMouseEvent);
					}

					parent.onMouseDown.dispatch(x, y, event.button);

					if (parent.onMouseDown.canceled) {
						event.preventDefault();
					}

				case "mouseenter":
					if (event.target == element) {
						parent.onEnter.dispatch();

						if (parent.onEnter.canceled) {
							event.preventDefault();
						}
					}

				case "mouseleave":
					if (event.target == element) {
						parent.onLeave.dispatch();

						if (parent.onLeave.canceled) {
							event.preventDefault();
						}
					}

				case "mouseup":
					Browser.window.removeEventListener("mouseup", handleMouseEvent);

					if (event.currentTarget == element) {
						event.stopPropagation();
					}

					parent.onMouseUp.dispatch(x, y, event.button);

					if (parent.onMouseUp.canceled) {
						event.preventDefault();
					}

				case "mousemove":
					if (x != cacheMouseX || y != cacheMouseY) {
						parent.onMouseMove.dispatch(x, y);

						if (parent.onMouseMove.canceled) {
							event.preventDefault();
						}
					}

				default:
			}

			cacheMouseX = x;
			cacheMouseY = y;
		} else {
			var event:WheelEvent = cast event;

			var deltaY = switch (event.deltaMode) {
				case WheelEvent.DOM_DELTA_LINE:
					Math.round(event.deltaY);

				case WheelEvent.DOM_DELTA_PIXEL:
					Math.round(event.deltaY / (scrollLineHeight * scale));

				case _: // WheelEvent.DOM_DELTA_PAGE and weird unknown ones

					if (event.deltaY < 0) -1 else if (event.deltaY > 0) 1 else 0;
			};

			parent.onMouseWheel.dispatch(-deltaY);

			if (parent.onMouseWheel.canceled) {
				event.preventDefault();
			}
		}
	}

	// See https://stackoverflow.com/a/37474225
	static function getScrollLineHeight():Int {
		if (!Browser.supported) {
			return 14;
		}
		var iframe:IFrameElement = cast Browser.document.createElement('iframe');
		iframe.src = '#';
		Browser.document.body.appendChild(iframe);
		var iwin = iframe.contentWindow;
		var idoc = iwin.document;
		idoc.open();
		idoc.write('<!DOCTYPE html><html><head></head><body><span>a</span></body></html>');
		idoc.close();
		var span = idoc.body.firstElementChild;
		var r = span.offsetHeight;
		Browser.document.body.removeChild(iframe);
		return r;
	}

	private function handlePasteEvent(event:ClipboardEvent):Void {
		event.preventDefault();

		var text = event.clipboardData.getData("text/plain");
		if (text == "")
			return;

		text = normalizeInputNewlines(text);
		Clipboard.setText(text, false);

		if (enableTextEvents) {
			parent.onTextPaste.dispatch(text);
		}
	}

	private function handleResizeEvent(event:js.html.Event):Void {
		primaryTouch = null;
		updateScale();
		updateSize();
	}

	private function handleTouchEvent(event:TouchEvent):Void {
		event.preventDefault();

		var rect = null;

		if (element != null) {
			if (canvas != null) {
				rect = canvas.getBoundingClientRect();
			} else {
				rect = element.getBoundingClientRect();
			}
		}

		var windowWidth:Float = setWidth;
		var windowHeight:Float = setHeight;

		if (windowWidth == 0 || windowHeight == 0) {
			if (rect != null) {
				windowWidth = rect.width;
				windowHeight = rect.height;
			} else {
				windowWidth = 1;
				windowHeight = 1;
			}
		}

		var touch, x, y, cacheX, cacheY;

		for (data in event.changedTouches) {
			x = 0.0;
			y = 0.0;

			if (rect != null) {
				x = (data.clientX - rect.left) * (windowWidth / rect.width);
				y = (data.clientY - rect.top) * (windowHeight / rect.height);
			} else {
				x = data.clientX;
				y = data.clientY;
			}

			if (event.type == "touchstart") {
				touch = unusedTouchesPool.pop();

				if (touch == null) {
					touch = new Touch(x / windowWidth, y / windowHeight, data.identifier, 0, 0, data.force, parent.id);
				} else {
					touch.x = x / windowWidth;
					touch.y = y / windowHeight;
					touch.id = data.identifier;
					touch.dx = 0;
					touch.dy = 0;
					touch.pressure = data.force;
					touch.device = parent.id;
				}

				currentTouches.set(data.identifier, touch);

				Touch.onStart.dispatch(touch);

				if (primaryTouch == null) {
					primaryTouch = touch;
				}

				if (touch == primaryTouch) {
					parent.onMouseDown.dispatch(x, y, 0);
				}
			} else {
				touch = currentTouches.get(data.identifier);

				if (touch != null) {
					cacheX = touch.x;
					cacheY = touch.y;

					touch.x = x / windowWidth;
					touch.y = y / windowHeight;
					touch.dx = touch.x - cacheX;
					touch.dy = touch.y - cacheY;
					touch.pressure = data.force;

					switch (event.type) {
						case "touchmove":
							Touch.onMove.dispatch(touch);

							if (touch == primaryTouch) {
								parent.onMouseMove.dispatch(x, y);
							}

						case "touchend":
							Touch.onEnd.dispatch(touch);

							currentTouches.remove(data.identifier);
							unusedTouchesPool.add(touch);

							if (touch == primaryTouch) {
								parent.onMouseUp.dispatch(x, y, 0);
								primaryTouch = null;
							}

						case "touchcancel":
							Touch.onCancel.dispatch(touch);

							currentTouches.remove(data.identifier);
							unusedTouchesPool.add(touch);

							if (touch == primaryTouch) {
								// parent.onMouseUp.dispatch (x, y, 0);
								primaryTouch = null;
							}

						default:
					}
				}
			}
		}
	}

	inline function normalizeInputNewlines(text:String):String {
		// normalize line breaks to `\n`, no matter if they were `\r\n` or just `\r`
		// so the API users (e.g. OpenFL) can assume that input newlines are always `\n`
		// this avoids issues with some browsers on Windows (e.g. Chrome) that paste
		// newlines as \r\n, as well as copying Flash text produced by Flash, which only
		// contain \r (https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#text)
		return StringTools.replace(StringTools.replace(text, "\r\n", "\n"), "\r", "\n");
	}

	private var settingSystemClipboard = false;

	public function setClipboard(value:String):Void {
		var inputEnabled = enableTextEvents;

		setEnableTextEvents(true); // create textInput if necessary

		var cacheText = textInput.value;
		textInput.value = value;
		textInput.select();

		settingSystemClipboard = true;
		if (Browser.document.queryCommandEnabled("copy")) {
			Browser.document.execCommand("copy");
		}
		settingSystemClipboard = false;

		textInput.value = cacheText;

		setEnableTextEvents(inputEnabled);
	}

	public function setEnableTextEvents(value:Bool):Bool {
		if (value) {
			if (textInput == null) {
				textInput = cast Browser.document.createElement('input');
				textInput.type = 'text';
				textInput.style.position = 'absolute';
				textInput.style.opacity = "0";
				textInput.style.color = "transparent";
				textInput.value = dummyCharacter; // See: handleInputEvent()

				(cast textInput).autocapitalize = "off";
				(cast textInput).autocorrect = "off";
				textInput.autocomplete = "off";

				// TODO: Position for mobile browsers better

				textInput.style.left = "0px";
				textInput.style.top = "50%";

				if (~/(iPad|iPhone|iPod).*OS 8_/gi.match(Browser.window.navigator.userAgent)) {
					textInput.style.fontSize = "0px";
					textInput.style.width = '0px';
					textInput.style.height = '0px';
				} else {
					textInput.style.width = '1px';
					textInput.style.height = '1px';
				}

				textInput.style.pointerEvents = 'none';
				textInput.style.zIndex = "-10000000";

				element.appendChild(textInput);
			}

			if (!enableTextEvents) {
				textInput.addEventListener('input', handleInputEvent, true);
				textInput.addEventListener('blur', handleFocusEvent, true);
				textInput.addEventListener('cut', handleCutEvent, true);
				textInput.addEventListener('copy', handleCopyEvent, true);
				textInput.addEventListener('paste', handlePasteEvent, true);
			}

			textInput.focus();
			textInput.select();
		} else {
			if (textInput != null) {
				textInput.removeEventListener('input', handleInputEvent, true);
				textInput.removeEventListener('blur', handleFocusEvent, true);
				textInput.removeEventListener('cut', handleCutEvent, true);
				textInput.removeEventListener('copy', handleCopyEvent, true);
				textInput.removeEventListener('paste', handlePasteEvent, true);

				textInput.blur();
			}
		}

		return enableTextEvents = value;
	}

	public function setFullscreen(value:Bool):Bool {
		if (value) {
			if (!requestedFullscreen && !isFullscreen) {
				requestedFullscreen = true;

				untyped {
					if (element.requestFullscreen) {
						document.addEventListener("fullscreenchange", handleFullscreenEvent, false);
						document.addEventListener("fullscreenerror", handleFullscreenEvent, false);
						element.requestFullscreen();
					} else if (element.mozRequestFullScreen) {
						document.addEventListener("mozfullscreenchange", handleFullscreenEvent, false);
						document.addEventListener("mozfullscreenerror", handleFullscreenEvent, false);
						element.mozRequestFullScreen();
					} else if (element.webkitRequestFullscreen) {
						document.addEventListener("webkitfullscreenchange", handleFullscreenEvent, false);
						document.addEventListener("webkitfullscreenerror", handleFullscreenEvent, false);
						element.webkitRequestFullscreen();
					} else if (element.msRequestFullscreen) {
						document.addEventListener("MSFullscreenChange", handleFullscreenEvent, false);
						document.addEventListener("MSFullscreenError", handleFullscreenEvent, false);
						element.msRequestFullscreen();
					}
				}
			}
		} else if (isFullscreen) {
			requestedFullscreen = false;

			untyped {
				if (document.exitFullscreen)
					document.exitFullscreen();
				else if (document.mozCancelFullScreen)
					document.mozCancelFullScreen();
				else if (document.webkitExitFullscreen)
					document.webkitExitFullscreen();
				else if (document.msExitFullscreen)
					document.msExitFullscreen();
			}
		}

		return value;
	}

	public function setTitle(value:String):String {
		if (value != null) {
			Browser.document.title = value;
		}

		return value;
	}

	private function updateScale():Void {
		if (parent.config != null && Reflect.hasField(parent.config, "allowHighDPI") && parent.config.allowHighDPI) {
			scale = Browser.window.devicePixelRatio;
		}

		parent.scale = scale;
	}

	private function updateSize():Void {
		if (!parent.__resizable)
			return;

		var elementWidth, elementHeight;

		if (element != null) {
			elementWidth = element.clientWidth;
			elementHeight = element.clientHeight;
		} else {
			elementWidth = Browser.window.innerWidth;
			elementHeight = Browser.window.innerHeight;
		}

		if (elementWidth != cacheElementWidth || elementHeight != cacheElementHeight) {
			cacheElementWidth = elementWidth;
			cacheElementHeight = elementHeight;

			var stretch = resizeElement || (setWidth == 0 && setHeight == 0);

			if (element != null) {
				if (stretch) {
					if (parent.width != elementWidth || parent.height != elementHeight) {
						parent.width = elementWidth;
						parent.height = elementHeight;

						if (canvas != null) {
							if (element != cast canvas) {
								canvas.width = Math.round(elementWidth * scale);
								canvas.height = Math.round(elementHeight * scale);

								canvas.style.width = elementWidth + "px";
								canvas.style.height = elementHeight + "px";
							}
						}

						parent.onResize.dispatch(elementWidth, elementHeight);
					}
				} else {
					var scaleX = (setWidth != 0) ? (elementWidth / setWidth) : 1;
					var scaleY = (setHeight != 0) ? (elementHeight / setHeight) : 1;

					var targetWidth = elementWidth;
					var targetHeight = elementHeight;
					var marginLeft = 0;
					var marginTop = 0;

					if (scaleX < scaleY) {
						targetHeight = Math.floor(setHeight * scaleX);
						marginTop = Math.floor((elementHeight - targetHeight) / 2);
					} else {
						targetWidth = Math.floor(setWidth * scaleY);
						marginLeft = Math.floor((elementWidth - targetWidth) / 2);
					}

					if (canvas != null) {
						if (element != cast canvas) {
							canvas.style.width = targetWidth + "px";
							canvas.style.height = targetHeight + "px";
							canvas.style.marginLeft = marginLeft + "px";
							canvas.style.marginTop = marginTop + "px";
						}
					}
				}
			}
		}
	}

	function close() {
		for (event in ["mousedown", "mouseenter", "mouseleave", "mousemove", "mouseup", "wheel"]) {
			element.removeEventListener(event, handleMouseEvent, true);
		}

		Browser.window.removeEventListener("mouseup", handleMouseEvent);

		parent.onClose.dispatch();
	}
}
