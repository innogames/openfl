package openfl.display;


import haxe.CallStack;
import lime.app.Application;
import lime.app.Config;
import lime.graphics.GLRenderContext;
import lime.ui.Gamepad;
import lime.ui.GamepadAxis;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Mouse in LimeMouse;
import lime.ui.Touch;
import lime.ui.Window;
import openfl._internal.TouchData;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.stage3D.opengl.GLTextureBase;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.EventPhase;
import openfl.events.FocusEvent;
import openfl.events.FullScreenEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.events.UncaughtErrorEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Transform;
import openfl.ui.GameInput;
import openfl.ui.Keyboard;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

#if hxtelemetry
import openfl.profiler.Telemetry;
#end

#if gl_stats
import openfl._internal.renderer.opengl.stats.GLStats;
#end

@:access(openfl._internal.renderer.AbstractRenderer)
@:access(openfl.display.LoaderInfo)
@:access(openfl.display.Sprite)
@:access(openfl.display.Stage3D)
@:access(openfl.events.Event)
@:access(openfl.geom.Point)
@:access(openfl.ui.GameInput)
@:access(openfl.ui.Keyboard)
@:access(openfl.ui.Mouse)
class Stage extends DisplayObjectContainer {
	
	
	public var align:StageAlign;
	public var allowsFullScreen (default, null):Bool;
	public var allowsFullScreenInteractive (default, null):Bool;
	public var application (default, null):Application;
	public var color (get, set):Null<Int>;
	public var contentsScaleFactor (get, never):Float;
	public var displayState (get, set):StageDisplayState;
	
	public var focus (get, set):InteractiveObject;
	public var frameRate (get, set):Float;
	public var fullScreenHeight (get, never):UInt;
	public var fullScreenWidth (get, never):UInt;
	public var quality:StageQuality;
	public var scaleMode:StageScaleMode;
	public var showDefaultContextMenu (get, set):Bool;
	public var softKeyboardRect:Rectangle;
	public var stage3Ds (default, null):Vector<Stage3D>;
	public var stageFocusRect:Bool;
	public var stageHeight (default, null):Int;
	public var stageWidth (default, null):Int;
	public var window (default, null):Window;
	
	private var __cacheFocus:InteractiveObject;
	private var __clearBeforeRender:Bool;
	private var __color:Int;
	private var __colorSplit:Array<Float>;
	private var __colorString:String;
	private var __contentsScaleFactor:Float;
	private var __displayMatrix:Matrix;
	private var __displayState:StageDisplayState;
	private var __dragBounds:Rectangle;
	private var __dragObject:Sprite;
	private var __dragOffsetX:Float;
	private var __dragOffsetY:Float;
	private var __focus:InteractiveObject;
	private var __fullscreen:Bool;
	private var __invalidated:Bool;
	private var __lastClickTime:Int;
	private var __logicalWidth:Int;
	private var __logicalHeight:Int;
	private var __macKeyboard:Bool;
	private var __mouseDownLeft:InteractiveObject;
	private var __mouseDownMiddle:InteractiveObject;
	private var __mouseDownRight:InteractiveObject;
	private var __mouseOverTarget:InteractiveObject;
	private var __mouseX:Float;
	private var __mouseY:Float;
	private var __primaryTouch:Touch;
	private var __renderer:GLRenderer;
	private var __rendering:Bool;
	private var __rollOutStack:Array<DisplayObject>;
	private var __mouseOutStack:Array<DisplayObject>;
	private var __stack:Array<DisplayObject>;
	private var __touchData:Map<Int, TouchData>;
	private var __transparent:Bool;
	private var __wasFullscreen:Bool;

	// TODO: this should be just a Stage constructor
	public static function create(documentFactory:()->DisplayObject, windowConfig:WindowConfig):Stage {
		var app = new lime.app.Application();
		app.create({windows: [windowConfig]});
		app.exec();

		var stage = app.stage;
		openfl.display.DisplayObject.__initStage = stage;
		stage.addChild(documentFactory());

		return stage;
	}
	
	function new (window:Window, color:Null<Int>) {
		
		#if hxtelemetry
		Telemetry.__initialize ();
		#end
		
		super ();
		
		this.application = window.application;
		this.window = window;
		this.color = color;
		
		this.name = null;
		
		__contentsScaleFactor = window.scale;
		__displayState = NORMAL;
		__mouseX = 0;
		__mouseY = 0;
		__lastClickTime = 0;
		__logicalWidth = 0;
		__logicalHeight = 0;
		__displayMatrix = new Matrix ();
		__renderDirty = true;
		__wasFullscreen = window.fullscreen;
		
		stage3Ds = new Vector ();
		stage3Ds.push (new Stage3D ());
		
		__resize ();
		
		this.stage = this;
		
		align = StageAlign.TOP_LEFT;
		allowsFullScreen = false;
		allowsFullScreenInteractive = false;
		quality = StageQuality.HIGH;
		scaleMode = StageScaleMode.NO_SCALE;
		showDefaultContextMenu = true;
		softKeyboardRect = new Rectangle ();
		stageFocusRect = true;

		__macKeyboard = new js.RegExp("AppleWebKit").test(js.Browser.navigator.userAgent) && new js.RegExp("Mobile\\/\\w+").test(js.Browser.navigator.userAgent) || new js.RegExp("Mac").test(js.Browser.navigator.userAgent);
		
		__clearBeforeRender = true;
		__stack = [];
		__rollOutStack = [];
		__mouseOutStack = [];
		__touchData = new Map<Int, TouchData>();
		
		if (Lib.current.stage == null) {
			
			stage.addChild (Lib.current);
			
		}
		
		
	}
	
	
	@:noCompletion public function __create (application:Application):Void {
		
		application.onExit.add (onModuleExit);
		
		for (gamepad in Gamepad.devices) {
			
			__onGamepadConnect (gamepad);
			
		}
		
		Gamepad.onConnect.add (__onGamepadConnect);
		Touch.onStart.add (onTouchStart);
		Touch.onMove.add (onTouchMove);
		Touch.onEnd.add (onTouchEnd);

		var renderer = window.renderer;
		renderer.onContextLost.add (onRenderContextLost);
		renderer.onContextRestored.add (onRenderContextRestored);

		window.onActivate.add (onWindowActivate);
		window.onClose.add (onWindowClose);
		window.onDeactivate.add (onWindowDeactivate);
		window.onEnter.add (onWindowEnter);
		window.onFocusIn.add (onWindowFocusIn);
		window.onFocusOut.add (onWindowFocusOut);
		window.onFullscreen.add (onWindowFullscreen);
		window.onKeyDown.add (onKeyDown);
		window.onKeyUp.add (onKeyUp);
		window.onLeave.add (onWindowLeave);
		window.onMinimize.add (onWindowMinimize);
		window.onMouseDown.add (onMouseDown);
		window.onMouseMove.add (onMouseMove);
		window.onMouseUp.add (onMouseUp);
		window.onMouseWheel.add (onMouseWheel);
		window.onResize.add (onWindowResize);
		window.onRestore.add (onWindowRestore);
		
		__createRenderer ();
		
	}
	
	
	public function invalidate ():Void {
		
		__invalidated = true;
		
	}
	
	
	public override function localToGlobal (pos:Point):Point {
		
		return pos.clone ();
		
	}
	
	
	public function onGamepadAxisMove (gamepad:Gamepad, axis:GamepadAxis, value:Float):Void {
		
		try {
			
			GameInput.__onGamepadAxisMove (gamepad, axis, value);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
	}
	
	
	public function onGamepadButtonDown (gamepad:Gamepad, button:GamepadButton):Void {
		
		try {
			
			GameInput.__onGamepadButtonDown (gamepad, button);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
	}
	
	
	public function onGamepadButtonUp (gamepad:Gamepad, button:GamepadButton):Void {
		
		try {
			
			GameInput.__onGamepadButtonUp (gamepad, button);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
	}
	
	
	public function onGamepadConnect (gamepad:Gamepad):Void {
		
		try {
			
			GameInput.__onGamepadConnect (gamepad);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
	}
	
	
	public function onGamepadDisconnect (gamepad:Gamepad):Void {
		
		try {
			
			GameInput.__onGamepadDisconnect (gamepad);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
	}
	
	
	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void {
		
		__onKey (KeyboardEvent.KEY_DOWN, keyCode, modifier);
		
	}
	
	
	public function onKeyUp (keyCode:KeyCode, modifier:KeyModifier):Void {
		
		__onKey (KeyboardEvent.KEY_UP, keyCode, modifier);
		
	}
	
	
	public function onModuleExit (code:Int):Void {
		
		if (window != null) {
			
			__broadcastEvent (new Event (Event.DEACTIVATE));
			
		}
		
	}
	
	
	public function onMouseDown (x:Float, y:Float, button:Int):Void {
		
		dispatchPendingMouseMove ();
		
		var type = switch (button) {
			
			case 1: MouseEvent.MIDDLE_MOUSE_DOWN;
			case 2: MouseEvent.RIGHT_MOUSE_DOWN;
			default: MouseEvent.MOUSE_DOWN;
			
		}
		
		__onMouse (type, Std.int (x * window.scale), Std.int (y * window.scale), button);
		
	}
	
	var hasPendingMouseMove = false;
	var pendingMouseMoveX:Int;
	var pendingMouseMoveY:Int;
	
	public function onMouseMove (x:Float, y:Float):Void {
		
		hasPendingMouseMove = true;
		pendingMouseMoveX = Std.int (x * window.scale);
		pendingMouseMoveY = Std.int (y * window.scale);
		
	}
	
	function dispatchPendingMouseMove () {
		
		if (hasPendingMouseMove) {
			__onMouse (MouseEvent.MOUSE_MOVE, pendingMouseMoveX, pendingMouseMoveY, 0);
			hasPendingMouseMove = false;
		}
		
	}
	
	public function onMouseUp (x:Float, y:Float, button:Int):Void {
		
		dispatchPendingMouseMove ();
		
		var type = switch (button) {
			
			case 1: MouseEvent.MIDDLE_MOUSE_UP;
			case 2: MouseEvent.RIGHT_MOUSE_UP;
			default: MouseEvent.MOUSE_UP;
			
		}
		
		__onMouse (type, Std.int (x * window.scale), Std.int (y * window.scale), button);

	}
	
	
	public function onMouseWheel (delta:Int):Void {
		
		dispatchPendingMouseMove ();
		
		__onMouseWheel (delta);
		
	}
	
	
	public function onRenderContextLost ():Void {
		
		__renderer = null;
		
		for (stage3D in stage3Ds) {
			
			stage3D.__loseContext ();
			
		}
		
	}
	
	
	public function onRenderContextRestored (context:GLRenderContext):Void {
		
		GLTextureBase.reset();
		__createRenderer ();
		__forceRenderDirty ();
		
	}
	
	
	public function onTouchMove (touch:Touch):Void {
		
		__onTouch (TouchEvent.TOUCH_MOVE, touch);
		
	}
	
	
	public function onTouchEnd (touch:Touch):Void {
		
		if (__primaryTouch == touch) {
			
			__primaryTouch = null;
			
		}
		
		__onTouch (TouchEvent.TOUCH_END, touch);
		
	}
	
	
	public function onTouchStart (touch:Touch):Void {
		
		if (__primaryTouch == null) {
			
			__primaryTouch = touch;
			
		}
		
		__onTouch (TouchEvent.TOUCH_BEGIN, touch);
		
	}
	
	
	public function onWindowActivate ():Void {
		
		//__broadcastEvent (new Event (Event.ACTIVATE));
		
	}
	
	
	public function onWindowClose ():Void {
		
		window = null;
		
		__primaryTouch = null;
		__broadcastEvent (new Event (Event.DEACTIVATE));
		
	}
	
	
	public function onWindowDeactivate ():Void {
		
		//__primaryTouch = null;
		//__broadcastEvent (new Event (Event.DEACTIVATE));
		
	}
	
	
	public function onWindowEnter ():Void {
		
		
	}
	
	
	public function onWindowFocusIn ():Void {
		
		__renderDirty = true;
		__broadcastEvent (new Event (Event.ACTIVATE));
		
		focus = __cacheFocus;
		
	}
	
	
	public function onWindowFocusOut ():Void {
		
		__primaryTouch = null;
		__broadcastEvent (new Event (Event.DEACTIVATE));
		
		var currentFocus = focus;
		focus = null;
		__cacheFocus = currentFocus;
		
	}
	
	
	public function onWindowFullscreen ():Void {
		
		__resize ();
		
		if (!__wasFullscreen) {
			
			__wasFullscreen = true;
			if (__displayState == NORMAL) __displayState = FULL_SCREEN_INTERACTIVE;
			__dispatchEvent (new FullScreenEvent (FullScreenEvent.FULL_SCREEN, false, false, true, true));
			
		}
		
	}
	
	
	public function onWindowLeave ():Void {
		
		if (MouseEvent.__buttonDown) return;
		
		__dispatchEvent (new Event (Event.MOUSE_LEAVE));
		
	}
	
	
	public function onWindowMinimize ():Void {
		
		//__primaryTouch = null;
		//__broadcastEvent (new Event (Event.DEACTIVATE));
		
	}
	
	
	public function onWindowResize (width:Int, height:Int):Void {
		
		__renderDirty = true;
		__resize ();
		
		__handleFullScreenRestore ();
		
	}
	
	
	public function onWindowRestore ():Void {
		
		__handleFullScreenRestore ();

	}
	
	inline function __handleFullScreenRestore() {
		if (__wasFullscreen && !window.fullscreen) {
			__wasFullscreen = false;
			__displayState = NORMAL;
			__dispatchEvent (new FullScreenEvent (FullScreenEvent.FULL_SCREEN, false, false, false, true));
		}		
	}
	
	
	@:noCompletion public function __onFrame (deltaTime:Int):Void {
		
		dispatchPendingMouseMove ();

		if (__rendering) return;
		__rendering = true;
		
		#if hxtelemetry
		Telemetry.__advanceFrame ();
		#end
		
		#if gl_stats
			GLStats.resetDrawCalls();
			GLStats.quadCounter.reset();
			GLStats.skippedQuadCounter.reset();
		#end
		
		if (__renderer != null && (Stage3D.__active || stage3Ds[0].__contextRequested)) {
			
			__renderer.clear ();
			__renderer.renderStage3D ();
			__renderDirty = true;
			
		}
		
		__broadcastEvent (new Event (Event.ENTER_FRAME));
		__broadcastEvent (new Event (Event.FRAME_CONSTRUCTED));
		__broadcastEvent (new Event (Event.EXIT_FRAME));
		
		if (__invalidated) {
			
			__invalidated = false;
			__broadcastEvent (new Event (Event.RENDER));
			
		}
		
		#if hxtelemetry
		var stack = Telemetry.__unwindStack ();
		Telemetry.__startTiming (TelemetryCommandName.RENDER);
		#end
		
		__renderable = true;
		
		__traverse ();
		
		if (__renderer != null #if !openfl_always_render && __renderDirty #end) {
			
			if (!Stage3D.__active) {
				
				__renderer.clear ();
				
			}
			
			__renderer.render ();
			
		}
		
		#if hxtelemetry
		Telemetry.__endTiming (TelemetryCommandName.RENDER);
		Telemetry.__rewindStack (stack);
		#end
		
		__rendering = false;
		
	}
	
	
	private function __broadcastEvent (event:Event):Void {
		
		if (DisplayObject.__broadcastEvents.exists (event.type)) {
			
			var dispatchers = DisplayObject.__broadcastEvents.get (event.type);
			
			for (dispatcher in dispatchers) {
				
				// TODO: Way to resolve dispatching occurring if object not on stage
				// and there are multiple stage objects running in HTML5?
				
				if (dispatcher.stage == this || dispatcher.stage == null) {
					
					try {
						
						dispatcher.__dispatch (event);
						
					} catch (e:Dynamic) {
						
						__handleError (e);
						
					}
					
				}
				
			}
			
		}
		
	}
	
	
	private function __createRenderer ():Void {
		
		__renderer = new GLRenderer (this, window.renderer.context);
		
	}
	
	
	private override function __dispatchEvent (event:Event):Bool {
		
		try {
			
			return super.__dispatchEvent (event);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			return false;
			
		}
		
	}
	
	
	private function __dispatchStack (event:Event, stack:Array<DisplayObject>):Void {
		
		try {
			
			var target:DisplayObject;
			var length = stack.length;
			
			if (length == 0) {
				
				event.eventPhase = EventPhase.AT_TARGET;
				target = cast event.target;
				target.__dispatch (event);
				
			} else {
				
				event.eventPhase = EventPhase.CAPTURING_PHASE;
				event.target = stack[stack.length - 1];
				
				for (i in 0...length - 1) {
					
					stack[i].__dispatch (event);
					
					if (event.__isCanceled) {
						
						return;
						
					}
					
				}
				
				event.eventPhase = EventPhase.AT_TARGET;
				target = cast event.target;
				target.__dispatch (event);
				
				if (event.__isCanceled) {
					
					return;
					
				}
				
				if (event.bubbles) {
					
					event.eventPhase = EventPhase.BUBBLING_PHASE;
					var i = length - 2;
					
					while (i >= 0) {
						
						stack[i].__dispatch (event);
						
						if (event.__isCanceled) {
							
							return;
							
						}
						
						i--;
						
					}
					
				}
				
			}
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			
		}
		
		
	}
	
	
	private function __dispatchTarget (target:EventDispatcher, event:Event):Bool {
		
		try {
			
			return target.__dispatchEvent (event);
			
		} catch (e:Dynamic) {
			
			__handleError (e);
			return false;
			
		}
		
	}
	
	
	private function __drag (mouse:Point):Void {
		
		var parent = __dragObject.parent;
		if (parent != null) {
			
			parent.__getWorldTransform ().__transformInversePoint (mouse);
			
		}
		
		var x = mouse.x + __dragOffsetX;
		var y = mouse.y + __dragOffsetY;
		
		if (__dragBounds != null) {
			
			if (x < __dragBounds.x) {
				
				x = __dragBounds.x;
				
			} else if (x > __dragBounds.right) {
				
				x = __dragBounds.right;
				
			}
			
			if (y < __dragBounds.y) {
				
				y = __dragBounds.y;
				
			} else if (y > __dragBounds.bottom) {
				
				y = __dragBounds.bottom;
				
			}
			
		}
		
		__dragObject.x = x;
		__dragObject.y = y;
		
	}
	
	
	private override function __getInteractive (stack:Array<DisplayObject>):Bool {
		
		if (stack != null) {
			
			stack.push (this);
			
		}
		
		return true;
		
	}
	
	
	private override function __globalToLocal (global:Point, local:Point):Point {
		
		if (global != local) {
			
			local.copyFrom (global);
			
		}
		
		return local;
		
	}
	
	
	private function __handleError (e:Dynamic):Void {
		
		var event = new UncaughtErrorEvent (UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, e);
		Lib.current.__loaderInfo.uncaughtErrorEvents.dispatchEvent (event);
		
		if (!event.__preventDefault) {
			
			#if mobile
			Log.println (CallStack.toString (CallStack.exceptionStack ()));
			Log.println (Std.string (e));
			#end
			
			#if cpp
			untyped __cpp__ ("throw e");
			#elseif neko
			neko.Lib.rethrow (e);
			#elseif js
			try {
				#if (haxe >= version("4.1.0-rc.1"))
				var exc = @:privateAccess haxe.NativeStackTrace.lastError;
				#else
				var exc = @:privateAccess haxe.CallStack.lastException;
				#end
				if (exc != null && Reflect.hasField (exc, "stack") && exc.stack != null && exc.stack != "") {
					js.Browser.console.log(exc.stack);
					e.stack = exc.stack;
				} else {
					var msg = CallStack.toString (CallStack.callStack ());
					js.Browser.console.log(msg);
				}
			} catch (e2:Dynamic) {}
			js.Syntax.code("throw {0}", e); // TODO: rethrow at the place of __handleError call instead
			#else
			throw e;
			#end
			
		}
		
	}
	
	
	
	private function __onKey (type:String, keyCode:KeyCode, modifier:KeyModifier):Void {
		
		dispatchPendingMouseMove ();
		
		MouseEvent.__altKey = modifier.altKey;
		MouseEvent.__commandKey = modifier.metaKey;
		MouseEvent.__ctrlKey = modifier.ctrlKey;
		MouseEvent.__shiftKey = modifier.shiftKey;
		
		var stack = new Array <DisplayObject> ();
		
		if (__focus == null) {
			
			__getInteractive (stack);
			
		} else {
			
			__focus.__getInteractive (stack);
			
		}
		
		if (stack.length > 0) {
			
			var keyLocation = Keyboard.__getKeyLocation (keyCode);
			var keyCode = Keyboard.__convertKeyCode (keyCode);
			var charCode = Keyboard.__getCharCode (keyCode, modifier.shiftKey);
			
			// Flash Player events are not cancelable, should we make only some events (like APP_CONTROL_BACK) cancelable?
			
			var event = new KeyboardEvent (type, true, true, charCode, keyCode, keyLocation, __macKeyboard ? modifier.ctrlKey || modifier.metaKey : modifier.ctrlKey, modifier.altKey, modifier.shiftKey, modifier.ctrlKey, modifier.metaKey);
			
			stack.reverse ();
			__dispatchStack (event, stack);
			
			if (event.__preventDefault) {
				
				if (type == KeyboardEvent.KEY_DOWN) {
					
					window.onKeyDown.cancel ();
					
				} else {
					
					window.onKeyUp.cancel ();
					
				}
				
			}
			
		}
		
	}
	
	
	private function __onGamepadConnect (gamepad:Gamepad):Void {
		
		onGamepadConnect (gamepad);
		
		gamepad.onAxisMove.add (onGamepadAxisMove.bind (gamepad));
		gamepad.onButtonDown.add (onGamepadButtonDown.bind (gamepad));
		gamepad.onButtonUp.add (onGamepadButtonUp.bind (gamepad));
		gamepad.onDisconnect.add (onGamepadDisconnect.bind (gamepad));
		
	}
	
	
	private function __onMouse (type:String, x:Float, y:Float, button:Int):Void {
		
		if (button > 2) return;
		
		var targetPoint = Point.__pool.get ();
		targetPoint.setTo (x, y);
		__displayMatrix.__transformInversePoint (targetPoint);
		
		__mouseX = targetPoint.x;
		__mouseY = targetPoint.y;
		
		var stack = [];
		var target:InteractiveObject = null;
		
		if (__hitTest (__mouseX, __mouseY, true, stack, true, this)) {
			
			target = cast stack[stack.length - 1];
			
		} else {
			
			target = this;
			stack = [ this ];
			
		}
		
		if (target == null) target = this;
		
		var clickType = null;
		
		switch (type) {
			
			case MouseEvent.MOUSE_DOWN:
			
				__maybeChangeFocus (target);
				__mouseDownLeft = target;
				MouseEvent.__buttonDown = true;
			
			case MouseEvent.MIDDLE_MOUSE_DOWN:
				
				__mouseDownMiddle = target;
			
			case MouseEvent.RIGHT_MOUSE_DOWN:
				
				__mouseDownRight = target;
			
			case MouseEvent.MOUSE_UP:
				
				if (__mouseDownLeft != null) {
					
					MouseEvent.__buttonDown = false;
					
					if (__mouseX < 0 || __mouseY < 0 || __mouseX > stageWidth || __mouseY > stageHeight) {
						
						__dispatchEvent (MouseEvent.__create (MouseEvent.RELEASE_OUTSIDE, 1, __mouseX, __mouseY, new Point (__mouseX, __mouseY), this));
						
					} else if (__mouseDownLeft == target) {
						
						clickType = MouseEvent.CLICK;
						
					}
					
					__mouseDownLeft = null;
					
				}
			
			case MouseEvent.MIDDLE_MOUSE_UP:
				
				if (__mouseDownMiddle == target) {
					
					clickType = MouseEvent.MIDDLE_CLICK;
					
				}
				
				__mouseDownMiddle = null;
			
			case MouseEvent.RIGHT_MOUSE_UP:
				
				if (__mouseDownRight == target) {
					
					clickType = MouseEvent.RIGHT_CLICK;
					
				}
				
				__mouseDownRight = null;
			
			default:
			
		}
		
		var localPoint = Point.__pool.get ();
		
		__dispatchStack (MouseEvent.__create (type, button, __mouseX, __mouseY, target.__globalToLocal (targetPoint, localPoint), target), stack);
		
		if (clickType != null) {
			
			__dispatchStack (MouseEvent.__create (clickType, button, __mouseX, __mouseY, target.__globalToLocal (targetPoint, localPoint), target), stack);
			
			if (type == MouseEvent.MOUSE_UP && cast (target, openfl.display.InteractiveObject).doubleClickEnabled) {
				
				var currentTime = Lib.getTimer ();
				if (currentTime - __lastClickTime < 500) {
					
					__dispatchStack (MouseEvent.__create (MouseEvent.DOUBLE_CLICK, button, __mouseX, __mouseY, target.__globalToLocal (targetPoint, localPoint), target), stack);
					__lastClickTime = 0;
					
				} else {
					
					__lastClickTime = currentTime;
					
				}
				
			}
			
		}
		
		if (Mouse.__cursor == MouseCursor.AUTO) {
			
			var cursor = null;
			
			if (__mouseDownLeft != null) {
				
				cursor = __mouseDownLeft.__getCursor ();
				
			} else {
				
				for (target in stack) {
					
					cursor = target.__getCursor ();
					
					if (cursor != null) {
						
						LimeMouse.cursor = cursor;
						break;
						
					}
					
				}
				
			}
			
			if (cursor == null) {
				
				LimeMouse.cursor = ARROW;
				
			}
			
		}
		
		var event;
		
		if (target != __mouseOverTarget) {
			
			if (__mouseOverTarget != null) {
				
				event = MouseEvent.__create (MouseEvent.MOUSE_OUT, button, __mouseX, __mouseY, __mouseOverTarget.__globalToLocal (targetPoint, localPoint), cast __mouseOverTarget);
				__dispatchStack (event, __mouseOutStack);
				
			}
			
		}
		
		for (target in __rollOutStack) {
			
			if (stack.indexOf (target) == -1) {
				
				__rollOutStack.remove (target);
				
				event = MouseEvent.__create (MouseEvent.ROLL_OUT, button, __mouseX, __mouseY, __mouseOverTarget.__globalToLocal (targetPoint, localPoint), cast __mouseOverTarget);
				event.bubbles = false;
				__dispatchTarget (target, event);
				
			}
			
		}
		
		for (target in stack) {
			
			if (__rollOutStack.indexOf (target) == -1 && __mouseOverTarget != null) {
				
				if (target.hasEventListener (MouseEvent.ROLL_OVER)) {
					
					event = MouseEvent.__create (MouseEvent.ROLL_OVER, button, __mouseX, __mouseY, __mouseOverTarget.__globalToLocal (targetPoint, localPoint), cast target);
					event.bubbles = false;
					__dispatchTarget (target, event);
					
				}
				
				if (target.hasEventListener (MouseEvent.ROLL_OUT)) {
					
					__rollOutStack.push (target);
					
				}
				
			}
			
		}
		
		if (target != __mouseOverTarget) {
			
			if (target != null) {
				
				event = MouseEvent.__create (MouseEvent.MOUSE_OVER, button, __mouseX, __mouseY, target.__globalToLocal (targetPoint, localPoint), cast target);
				__dispatchStack (event, stack);
				
			}
			
			__mouseOverTarget = target;
			__mouseOutStack = stack;
			
		}
		
		if (__dragObject != null) {
			
			__drag (targetPoint);
			
			var dropTarget = null;
			
			if (__mouseOverTarget == __dragObject) {
				
				var cacheMouseEnabled = __dragObject.mouseEnabled;
				var cacheMouseChildren = __dragObject.mouseChildren;
				
				__dragObject.mouseEnabled = false;
				__dragObject.mouseChildren = false;
				
				var stack = [];
				
				if (__hitTest (__mouseX, __mouseY, true, stack, true, this)) {
					
					dropTarget = stack[stack.length - 1];
					
				}
				
				__dragObject.mouseEnabled = cacheMouseEnabled;
				__dragObject.mouseChildren = cacheMouseChildren;
				
			} else if (__mouseOverTarget != this) {
				
				dropTarget = __mouseOverTarget;
				
			}
			
			__dragObject.dropTarget = dropTarget;
			
		}
		
		Point.__pool.release (targetPoint);
		Point.__pool.release (localPoint);
		
	}
	
	
	private function __maybeChangeFocus (target:InteractiveObject) {

		var currentFocus = __focus;
		var newFocus = if (target.__allowMouseFocus ()) target else null;
		
		if (currentFocus != newFocus) {
			
			if (currentFocus != null) {
				
				// we always set `event.relatedObject` to `target` even if it's not focusable, because that's how it is in Flash
				var event = new FocusEvent (FocusEvent.MOUSE_FOCUS_CHANGE, true, true, target, false, 0);
				
				currentFocus.dispatchEvent(event);
				
				if (event.isDefaultPrevented()) {
					
					return;
					
				}
				
			}
			
			focus = newFocus;
			
		}
		
	}
	
	
	private function __onMouseWheel (delta:Int):Void {
		
		var x = __mouseX;
		var y = __mouseY;
		
		var stack = [];
		var target:InteractiveObject = null;
		
		if (__hitTest (__mouseX, __mouseY, true, stack, true, this)) {
			
			target = cast stack[stack.length - 1];
			
		} else {
			
			target = this;
			stack = [ this ];
			
		}
		
		if (target == null) target = this;
		var targetPoint = Point.__pool.get ();
		targetPoint.setTo (x, y);
		__displayMatrix.__transformInversePoint (targetPoint);
		
		// Flash API docs say it can be a greater value when scrolling fast,
		// but I couldn't figure out how to get the `3` from Chrome's pixel delta (it's around 6 for me)
		if (delta < -3) delta = -3
		else if (delta > 3) delta = 3;
		
		__dispatchStack (MouseEvent.__create (MouseEvent.MOUSE_WHEEL, 0, __mouseX, __mouseY, target.__globalToLocal (targetPoint, targetPoint), target, delta), stack);
		
		Point.__pool.release (targetPoint);
		
	}
	
	
	private function __onTouch (type:String, touch:Touch):Void {
		
		var targetPoint = Point.__pool.get ();
		targetPoint.setTo (Math.round (touch.x * window.width * window.scale), Math.round (touch.y * window.height * window.scale));
		__displayMatrix.__transformInversePoint (targetPoint);
		
		var touchX = targetPoint.x;
		var touchY = targetPoint.y;
		
		var stack = [];
		var target:InteractiveObject = null;
		
		if (__hitTest (touchX, touchY, false, stack, true, this)) {
			
			target = cast stack[stack.length - 1];
			
		}
		else {
			
			target = this;
			stack = [ this ];
			
		}
		
		if (target == null) target = this;
		
		var touchId:Int = touch.id;
		var touchData:TouchData = null;
		
		if (__touchData.exists (touchId)) {
			
			touchData = __touchData.get (touchId);
			
		} else {
			
			touchData = TouchData.__pool.get ();
			touchData.reset ();
			touchData.touch = touch;
			__touchData.set (touchId, touchData);
			
		}
		
		var touchType = null;
		var releaseTouchData:Bool = false;
		
		switch (type) {
			
			case TouchEvent.TOUCH_BEGIN:
			
				touchData.touchDownTarget = target;
			
			case TouchEvent.TOUCH_END:
				
				if (touchData.touchDownTarget == target) {
					
					touchType = TouchEvent.TOUCH_TAP;
					
				}
				
				touchData.touchDownTarget = null;
				releaseTouchData = true;
			
			default:
			
			
		}
		
		var localPoint = Point.__pool.get ();
		var isPrimaryTouchPoint:Bool = (__primaryTouch == touch);
		var touchEvent = TouchEvent.__create (type, null, touchX, touchY, target.__globalToLocal (targetPoint, localPoint), cast target);
		touchEvent.touchPointID = touchId;
		touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
		
		__dispatchStack (touchEvent, stack);
		
		if (touchType != null) {
			
			touchEvent = TouchEvent.__create (touchType, null, touchX, touchY, target.__globalToLocal (targetPoint, localPoint), cast target);
			touchEvent.touchPointID = touchId;
			touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
			
			__dispatchStack (touchEvent, stack);
			
		}
		
		var touchOverTarget = touchData.touchOverTarget;
		
		if (target != touchOverTarget && touchOverTarget != null) {
			
			touchEvent = TouchEvent.__create (TouchEvent.TOUCH_OUT, null, touchX, touchY, touchOverTarget.__globalToLocal (targetPoint, localPoint), cast touchOverTarget);
			touchEvent.touchPointID = touchId;
			touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
			
			__dispatchTarget (touchOverTarget, touchEvent);
			
		}
		
		var touchOutStack = touchData.rollOutStack;
		
		for (target in touchOutStack) {
			
			if (stack.indexOf (target) == -1) {
				
				touchOutStack.remove (target);
				
				touchEvent = TouchEvent.__create (TouchEvent.TOUCH_ROLL_OUT, null, touchX, touchY, touchOverTarget.__globalToLocal (targetPoint, localPoint), cast touchOverTarget);
				touchEvent.touchPointID = touchId;
				touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
				touchEvent.bubbles = false;
				
				__dispatchTarget (target, touchEvent);
				
			}
			
		}
		
		for (target in stack) {
			
			if (touchOutStack.indexOf (target) == -1) {
				
				if (target.hasEventListener (TouchEvent.TOUCH_ROLL_OVER)) {
					
					touchEvent = TouchEvent.__create (TouchEvent.TOUCH_ROLL_OVER, null, touchX, touchY, touchOverTarget.__globalToLocal (targetPoint, localPoint), cast target);
					touchEvent.touchPointID = touchId;
					touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
					touchEvent.bubbles = false;
					
					__dispatchTarget (target, touchEvent);
					
				}
				
				if (target.hasEventListener (TouchEvent.TOUCH_ROLL_OUT)) {
					
					touchOutStack.push (target);
					
				}
				
			}
			
		}
		
		if (target != touchOverTarget) {
			
			if (target != null) {
				
				touchEvent = TouchEvent.__create (TouchEvent.TOUCH_OVER, null, touchX, touchY, target.__globalToLocal (targetPoint, localPoint), cast target);
				touchEvent.touchPointID = touchId;
				touchEvent.isPrimaryTouchPoint = isPrimaryTouchPoint;
				touchEvent.bubbles = true;
				
				__dispatchTarget (target, touchEvent);
				
			}
			
			touchData.touchOverTarget = target;
			
		}
		
		Point.__pool.release (targetPoint);
		Point.__pool.release (localPoint);
		
		if (releaseTouchData) {
			
			__touchData.remove (touchId);
			touchData.reset ();
			TouchData.__pool.release (touchData);
			
		}
		
	}
	
	
	private function __resize ():Void {
		
		var cacheWidth = stageWidth;
		var cacheHeight = stageHeight;
		
		var windowWidth = Std.int (window.width * window.scale);
		var windowHeight = Std.int (window.height * window.scale);
		
		__logicalWidth = window.width;
		__logicalHeight = window.height;
		
		__displayMatrix.identity ();
		
		if (__logicalWidth == 0 && __logicalHeight == 0) {
			
			stageWidth = windowWidth;
			stageHeight = windowHeight;
			
		} else {
			
			stageWidth = __logicalWidth;
			stageHeight = __logicalHeight;
			
			var scaleX = windowWidth / stageWidth;
			var scaleY = windowHeight / stageHeight;
			var targetScale = Math.min (scaleX, scaleY);
			
			var offsetX = Math.round ((windowWidth - (stageWidth * targetScale)) / 2);
			var offsetY = Math.round ((windowHeight - (stageHeight * targetScale)) / 2);
			
			__displayMatrix.scale (targetScale, targetScale);
			__displayMatrix.translate (offsetX, offsetY);
			
		}
		
		if (__contentsScaleFactor != window.scale && __renderer != null) {
			
			__contentsScaleFactor = window.scale;
			
			@:privateAccess (__renderer.renderSession).pixelRatio = window.scale;
			
			__forceRenderDirty();
			
		}
		
		if (__renderer != null) {
			
			__renderer.resize (windowWidth, windowHeight);
			
		}
		
		if (stageWidth != cacheWidth || stageHeight != cacheHeight) {
			
			__dispatchEvent (new Event (Event.RESIZE));
			
		}
		
	}
	
	
	private function __setLogicalSize (width:Int, height:Int):Void {
		
		__logicalWidth = width;
		__logicalHeight = height;
		
		__resize ();
		
	}
	
	
	private function __startDrag (sprite:Sprite, lockCenter:Bool, bounds:Rectangle):Void {
		
		if (bounds == null) {
			
			__dragBounds = null;
			
		} else {
			
			__dragBounds = new Rectangle ();
			
			var right = bounds.right;
			var bottom = bounds.bottom;
			__dragBounds.x = right < bounds.x ? right : bounds.x;
			__dragBounds.y = bottom < bounds.y ? bottom : bounds.y;
			__dragBounds.width = Math.abs (bounds.width);
			__dragBounds.height = Math.abs (bounds.height);
			
		}
		
		__dragObject = sprite;
		
		if (__dragObject != null) {
			
			if (lockCenter) {
				
				__dragOffsetX = 0;
				__dragOffsetY = 0;
				
			} else {
				
				var mouse = Point.__pool.get ();
				mouse.setTo (mouseX, mouseY);
				var parent = __dragObject.parent;
				
				if (parent != null) {
					
					parent.__getWorldTransform ().__transformInversePoint (mouse);
					
				}
				
				__dragOffsetX = __dragObject.x - mouse.x;
				__dragOffsetY = __dragObject.y - mouse.y;
				Point.__pool.release (mouse);
				
			}
			
		}
		
	}
	
	
	private function __stopDrag (sprite:Sprite):Void {
		
		__dragBounds = null;
		__dragObject = null;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_color ():Null<Int> {
		
		return __color;
		
	}
	
	
	private function set_color (value:Null<Int>):Null<Int> {
		
		if (value == null) {
			
			__transparent = true;
			value = 0x000000;
			
		} else {
			
			__transparent = false;
			
		}
		
		var r = (value & 0xFF0000) >>> 16;
		var g = (value & 0x00FF00) >>> 8;
		var b = (value & 0x0000FF);
		
		__colorSplit = [ r / 0xFF, g / 0xFF, b / 0xFF ];
		__colorString = "#" + StringTools.hex (value & 0xFFFFFF, 6);
		
		return __color = value;
		
	}
	
	
	private function get_contentsScaleFactor ():Float {
		
		return __contentsScaleFactor;
		
	}
	
	
	private function get_displayState ():StageDisplayState {
		
		return __displayState;
		
	}
	
	
	private function set_displayState (value:StageDisplayState):StageDisplayState {
		
		if (window != null) {
			
			switch (value) {
				
				case NORMAL:
					
					if (window.fullscreen) {
						
						//window.minimized = false;
						window.fullscreen = false;
						
					}
				
				default:
					
					if (!window.fullscreen) {
						
						//window.minimized = false;
						window.fullscreen = true;
						
					}
				
			}
			
		}
		
		return __displayState = value;
		
	}
	
	
	private function get_focus ():InteractiveObject {
		
		return __focus;
		
	}
	
	
	private function set_focus (value:InteractiveObject):InteractiveObject {
		
		if (value != __focus) {
			
			var oldFocus = __focus;
			__focus = value;
			__cacheFocus = value;
			
			if (oldFocus != null) {
				
				var event = new FocusEvent (FocusEvent.FOCUS_OUT, true, false, value, false, 0);
				var stack = new Array <DisplayObject> ();
				oldFocus.__getInteractive (stack);
				stack.reverse ();
				__dispatchStack (event, stack);
				
			}
			
			if (value != null) {
				
				var event = new FocusEvent (FocusEvent.FOCUS_IN, true, false, oldFocus, false, 0);
				var stack = new Array <DisplayObject> ();
				value.__getInteractive (stack);
				stack.reverse ();
				__dispatchStack (event, stack);
				
			}
			
		}
		
		return value;
		
	}
	
	
	private function get_frameRate ():Float {
		
		if (application != null) {
			
			return application.frameRate;
			
		}
		
		return 0;
		
	}
	
	
	private function set_frameRate (value:Float):Float {
		
		if (application != null) {
			
			return application.frameRate = value;
			
		}
		
		return value;
		
	}
	
	
	private function get_fullScreenHeight ():UInt {
		
		return Math.ceil (window.displayHeight * window.scale);
		
	}
	
	
	private function get_fullScreenWidth ():UInt {
		
		return Math.ceil (window.displayWidth * window.scale);
		
	}

	private function set_showDefaultContextMenu (value:Bool):Bool {

		if (window != null) {

			return window.enableContextMenuEvents = value;

		}

		return value;

	}


	private function get_showDefaultContextMenu ():Bool {

		if (window != null) {

			return window.enableContextMenuEvents;

		}

		return true;

	}


	private override function set_height (value:Float):Float {
		
		return this.height;
		
	}
	
	
	private override function get_mouseX ():Float {
		
		return __mouseX;
		
	}
	
	
	private override function get_mouseY ():Float {
		
		return __mouseY;
		
	}
	
	
	private override function set_rotation (value:Float):Float {
		
		return 0;
		
	}
	
	
	private override function set_scaleX (value:Float):Float {
		
		return 0;
		
	}
	
	
	private override function set_scaleY (value:Float):Float {
		
		return 0;
		
	}
	
	
	private override function set_transform (value:Transform):Transform {
		
		return this.transform;
		
	}
	
	
	private override function set_width (value:Float):Float {
		
		return this.width;
		
	}
	
	
	private override function set_x (value:Float):Float {
		
		return 0;
		
	}
	
	
	private override function set_y (value:Float):Float {
		
		return 0;
		
	}
	
	
}
