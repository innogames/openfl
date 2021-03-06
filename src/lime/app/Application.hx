package lime.app;

import js.Browser;
import js.html.KeyboardEvent;
import lime.graphics.Renderer;
import lime.system.System;
import lime.ui.Window;
import lime.ui.GamepadAxis;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import lime.ui.Joystick;
import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl._internal.Lib;

@:access(lime._backend.html5.HTML5Window)
@:access(lime.ui.Gamepad)
@:access(lime.ui.Joystick)
@:access(lime.ui.Window)
class Application {
	public static var current(default, null):Application;

	public var config(default, null):Config;

	/**
	 * The current frame rate (measured in frames-per-second) of the application.
	 *
	 * On some platforms, a frame rate of 60 or greater may imply vsync, which will
	 * perform more quickly on displays with a higher refresh rate
	**/
	public var frameRate(get, set):Float;

	public var stage(default, null):Stage;
	public var window(default, null):Window;
	public var renderer(default, null):Renderer;

	public var onExit = new Event<Int->Void>();

	private var gameDeviceCache = new Map<Int, GameDeviceData>();

	private var currentUpdate:Float;
	private var deltaTime:Float;
	private var framePeriod:Float;
	private var lastUpdate:Float;
	private var nextUpdate:Float;

	public function new() {
		if (Application.current == null) {
			Application.current = this;
		}

		currentUpdate = 0;
		lastUpdate = 0;
		nextUpdate = 0;
		framePeriod = -1;
	}

	@:access(openfl.display.DisplayObject)
	@:access(openfl.display.LoaderInfo)
	@:access(openfl.display.Stage.new)
	public function create(config:Config):Void {
		this.config = config;

		var windowConfig = config.windows[0];

		var loaderInfo = LoaderInfo.create(null);
		if (windowConfig.parameters != null) {
			loaderInfo.parameters = windowConfig.parameters;
		}

		if (Lib.current == null)
			Lib.current = new Sprite();
		Lib.current.__loaderInfo = loaderInfo;
		Lib.current.__loaderInfo.content = Lib.current;

		if (Reflect.hasField(config, "fps")) {
			frameRate = config.fps;
		}

		window = new Window(windowConfig);
		renderer = window.renderer; // TODO: remove this

		window.onClose.add(onWindowClose);
		window.create(this);

		stage = new Stage(window, Reflect.hasField(windowConfig, "background") ? windowConfig.background : 0xFFFFFF);

		if (Reflect.hasField(windowConfig, "resizable") && !windowConfig.resizable) {
			stage.__setLogicalSize(windowConfig.width, windowConfig.height);
		}

		stage.__create(this);
	}

	function onWindowClose() {
		window = null;
		renderer = null;
	}

	public function exec() {
		Application.current = this;

		Browser.window.addEventListener("keydown", handleKeyEvent, false);
		Browser.window.addEventListener("keyup", handleKeyEvent, false);
		Browser.window.addEventListener("focus", handleWindowEvent, false);
		Browser.window.addEventListener("blur", handleWindowEvent, false);
		Browser.window.addEventListener("resize", handleWindowEvent, false);
		Browser.window.addEventListener("beforeunload", handleWindowEvent, false);

		lastUpdate = Date.now().getTime();

		handleApplicationEvent(0);
	}

	private function handleApplicationEvent(_) {
		if (window == null) {
			return; // app is closing
		}

		Browser.window.requestAnimationFrame(handleApplicationEvent);

		window.backend.updateSize();

		updateGameDevices();

		currentUpdate = Date.now().getTime();

		if (currentUpdate >= nextUpdate) {
			deltaTime = currentUpdate - lastUpdate;

			stage.__onFrame(Std.int(deltaTime));

			if (framePeriod < 0) {
				nextUpdate = currentUpdate;
			} else {
				nextUpdate = currentUpdate + framePeriod;

				// while (nextUpdate <= currentUpdate) {
				//
				// nextUpdate += framePeriod;
				//
				// }
			}

			lastUpdate = currentUpdate;
		}
	}

	private function handleWindowEvent(event:js.html.Event):Void {
		if (window == null)
			return;

		switch (event.type) {
			case "focus":
				window.onFocusIn.dispatch();
				window.onActivate.dispatch();

			case "blur":
				window.onFocusOut.dispatch();
				window.onDeactivate.dispatch();

			case "resize":
				window.backend.handleResizeEvent(event);

			case "beforeunload":
				if (!event.defaultPrevented) {
					window.backend.close();
				}
		}
	}

	private function handleKeyEvent(event:KeyboardEvent):Void {
		if (window == null)
			return;

		var keyCode = cast convertKeyCode(event.keyCode != null ? event.keyCode : event.which);
		var modifier = (event.shiftKey ? (KeyModifier.SHIFT) : 0) | (event.ctrlKey ? (KeyModifier.CTRL) : 0) | (event.altKey ? (KeyModifier.ALT) : 0) | (event.metaKey ? (KeyModifier.META) : 0);

		if (event.type == "keydown") {
			window.onKeyDown.dispatch(keyCode, modifier);

			if (window.onKeyDown.canceled) {
				event.preventDefault();
			}
		} else {
			window.onKeyUp.dispatch(keyCode, modifier);

			if (window.onKeyUp.canceled) {
				event.preventDefault();
			}
		}
	}

	private function updateGameDevices():Void {
		var devices = Joystick.__getDeviceData();
		if (devices == null)
			return;

		var id, gamepad, joystick, data:Dynamic, cache;

		for (i in 0...devices.length) {
			id = i;
			data = devices[id];

			if (data == null)
				continue;

			if (!gameDeviceCache.exists(id)) {
				cache = new GameDeviceData();
				cache.id = id;
				cache.connected = data.connected;

				for (i in 0...data.buttons.length) {
					cache.buttons.push(data.buttons[i].value);
				}

				for (i in 0...data.axes.length) {
					cache.axes.push(data.axes[i]);
				}

				if (data.mapping == "standard") {
					cache.isGamepad = true;
				}

				gameDeviceCache.set(id, cache);

				if (data.connected) {
					Joystick.__connect(id);

					if (cache.isGamepad) {
						Gamepad.__connect(id);
					}
				}
			}

			cache = gameDeviceCache.get(id);

			joystick = Joystick.devices.get(id);
			gamepad = Gamepad.devices.get(id);

			if (data.connected) {
				var button:GamepadButton;
				var value:Float;

				for (i in 0...data.buttons.length) {
					value = data.buttons[i].value;

					if (value != cache.buttons[i]) {
						if (i == 6) {
							joystick.onAxisMove.dispatch(data.axes.length, value);
							if (gamepad != null)
								gamepad.onAxisMove.dispatch(GamepadAxis.TRIGGER_LEFT, value);
						} else if (i == 7) {
							joystick.onAxisMove.dispatch(data.axes.length + 1, value);
							if (gamepad != null)
								gamepad.onAxisMove.dispatch(GamepadAxis.TRIGGER_RIGHT, value);
						} else {
							if (value > 0) {
								joystick.onButtonDown.dispatch(i);
							} else {
								joystick.onButtonUp.dispatch(i);
							}

							if (gamepad != null) {
								button = switch (i) {
									case 0: GamepadButton.A;
									case 1: GamepadButton.B;
									case 2: GamepadButton.X;
									case 3: GamepadButton.Y;
									case 4: GamepadButton.LEFT_SHOULDER;
									case 5: GamepadButton.RIGHT_SHOULDER;
									case 8: GamepadButton.BACK;
									case 9: GamepadButton.START;
									case 10: GamepadButton.LEFT_STICK;
									case 11: GamepadButton.RIGHT_STICK;
									case 12: GamepadButton.DPAD_UP;
									case 13: GamepadButton.DPAD_DOWN;
									case 14: GamepadButton.DPAD_LEFT;
									case 15: GamepadButton.DPAD_RIGHT;
									case 16: GamepadButton.GUIDE;
									default: continue;
								}

								if (value > 0) {
									gamepad.onButtonDown.dispatch(button);
								} else {
									gamepad.onButtonUp.dispatch(button);
								}
							}
						}

						cache.buttons[i] = value;
					}
				}

				for (i in 0...data.axes.length) {
					if (data.axes[i] != cache.axes[i]) {
						joystick.onAxisMove.dispatch(i, data.axes[i]);
						if (gamepad != null)
							gamepad.onAxisMove.dispatch(i, data.axes[i]);
						cache.axes[i] = data.axes[i];
					}
				}
			} else if (cache.connected) {
				cache.connected = false;

				Joystick.__disconnect(id);
				Gamepad.__disconnect(id);
			}
		}
	}

	function get_frameRate():Float {
		if (framePeriod < 0) {
			return 60;
		} else if (framePeriod == 1000) {
			return 0;
		} else {
			return 1000 / framePeriod;
		}
	}

	function set_frameRate(value:Float):Float {
		if (value >= 60) {
			framePeriod = -1;
		} else if (value > 0) {
			framePeriod = 1000 / value;
		} else {
			framePeriod = 1000;
		}

		return value;
	}

	static function convertKeyCode(keyCode:Int):KeyCode {
		if (keyCode >= 65 && keyCode <= 90) {
			return keyCode + 32;
		}

		switch (keyCode) {
			case 16:
				return KeyCode.LEFT_SHIFT;
			case 17:
				return KeyCode.LEFT_CTRL;
			case 18:
				return KeyCode.LEFT_ALT;
			case 20:
				return KeyCode.CAPS_LOCK;
			case 33:
				return KeyCode.PAGE_UP;
			case 34:
				return KeyCode.PAGE_DOWN;
			case 35:
				return KeyCode.END;
			case 36:
				return KeyCode.HOME;
			case 37:
				return KeyCode.LEFT;
			case 38:
				return KeyCode.UP;
			case 39:
				return KeyCode.RIGHT;
			case 40:
				return KeyCode.DOWN;
			case 45:
				return KeyCode.INSERT;
			case 46:
				return KeyCode.DELETE;
			case 96:
				return KeyCode.NUMPAD_0;
			case 97:
				return KeyCode.NUMPAD_1;
			case 98:
				return KeyCode.NUMPAD_2;
			case 99:
				return KeyCode.NUMPAD_3;
			case 100:
				return KeyCode.NUMPAD_4;
			case 101:
				return KeyCode.NUMPAD_5;
			case 102:
				return KeyCode.NUMPAD_6;
			case 103:
				return KeyCode.NUMPAD_7;
			case 104:
				return KeyCode.NUMPAD_8;
			case 105:
				return KeyCode.NUMPAD_9;
			case 106:
				return KeyCode.NUMPAD_MULTIPLY;
			case 107:
				return KeyCode.NUMPAD_PLUS;
			case 109:
				return KeyCode.NUMPAD_MINUS;
			case 110:
				return KeyCode.NUMPAD_PERIOD;
			case 111:
				return KeyCode.NUMPAD_DIVIDE;
			case 112:
				return KeyCode.F1;
			case 113:
				return KeyCode.F2;
			case 114:
				return KeyCode.F3;
			case 115:
				return KeyCode.F4;
			case 116:
				return KeyCode.F5;
			case 117:
				return KeyCode.F6;
			case 118:
				return KeyCode.F7;
			case 119:
				return KeyCode.F8;
			case 120:
				return KeyCode.F9;
			case 121:
				return KeyCode.F10;
			case 122:
				return KeyCode.F11;
			case 123:
				return KeyCode.F12;
			case 124:
				return KeyCode.F13;
			case 125:
				return KeyCode.F14;
			case 126:
				return KeyCode.F15;
			case 144:
				return KeyCode.NUM_LOCK;
			case 186:
				return KeyCode.SEMICOLON;
			case 187:
				return KeyCode.EQUALS;
			case 188:
				return KeyCode.COMMA;
			case 189:
				return KeyCode.MINUS;
			case 190:
				return KeyCode.PERIOD;
			case 191:
				return KeyCode.SLASH;
			case 192:
				return KeyCode.GRAVE;
			case 219:
				return KeyCode.LEFT_BRACKET;
			case 220:
				return KeyCode.BACKSLASH;
			case 221:
				return KeyCode.RIGHT_BRACKET;
			case 222:
				return KeyCode.SINGLE_QUOTE;
		}

		return keyCode;
	}
}

private class GameDeviceData {
	public var connected:Bool;
	public var id:Int;
	public var isGamepad:Bool;
	public var buttons:Array<Float>;
	public var axes:Array<Float>;

	public function new() {
		connected = true;
		buttons = [];
		axes = [];
	}
}
