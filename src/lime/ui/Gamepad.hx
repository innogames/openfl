package lime.ui;

import lime.app.Event;

@:access(lime.ui.Joystick)
class Gamepad {
	public static var devices = new Map<Int, Gamepad>();
	public static var onConnect = new Event<Gamepad->Void>();

	public var connected(default, null):Bool;
	public var guid(get, never):String;
	public var id(default, null):Int;
	public var name(get, never):String;
	public var onAxisMove = new Event<GamepadAxis->Float->Void>();
	public var onButtonDown = new Event<GamepadButton->Void>();
	public var onButtonUp = new Event<GamepadButton->Void>();
	public var onDisconnect = new Event<Void->Void>();

	public function new(id:Int) {
		this.id = id;
		connected = true;
	}

	@:noCompletion private static function __connect(id:Int):Void {
		if (!devices.exists(id)) {
			var gamepad = new Gamepad(id);
			devices.set(id, gamepad);
			onConnect.dispatch(gamepad);
		}
	}

	@:noCompletion private static function __disconnect(id:Int):Void {
		var gamepad = devices.get(id);
		if (gamepad != null)
			gamepad.connected = false;
		devices.remove(id);
		if (gamepad != null)
			gamepad.onDisconnect.dispatch();
	}

	// Get & Set Methods

	@:noCompletion private inline function get_guid():String {
		var devices = Joystick.__getDeviceData();
		return devices[this.id].id;
	}

	@:noCompletion private inline function get_name():String {
		var devices = Joystick.__getDeviceData();
		return devices[this.id].id;
	}
}
