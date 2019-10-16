package lime.ui;

import lime._backend.html5.HTML5Mouse as MouseBackend;

class Mouse {
	public static var cursor(get, set):MouseCursor;

	public static function hide():Void {
		MouseBackend.hide();
	}

	public static function show():Void {
		MouseBackend.show();
	}

	static function get_cursor():MouseCursor {
		return MouseBackend.get_cursor();
	}

	static function set_cursor(value:MouseCursor):MouseCursor {
		return MouseBackend.set_cursor(value);
	}
}
