package lime.system;

import lime.app.Application;

@:access(lime.ui.Window)
class Clipboard {
	public static var text(get, set):String;

	private static var _text:String;

	private static inline function get_text():String {
		return _text;
	}

	private static inline function set_text(value:String):String {
		setText(value, true);

		return value;
	}

	public static function setText(value:String, syncSystemClipboard:Bool) {
		_text = value;

		if (syncSystemClipboard) {
			var window = Application.current.window;
			if (window != null) {
				window.backend.setClipboard(value);
			}
		}
	}
}
