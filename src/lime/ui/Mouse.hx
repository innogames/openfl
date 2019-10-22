package lime.ui;

import lime.app.Application;

@:access(lime.app.Application)
@:access(lime.ui.Window)
class Mouse {
	public static var cursor(get, set):MouseCursor;

	static var __cursor:MouseCursor;
	static var __hidden:Bool;

	public static function hide():Void {
		if (!__hidden) {
			__hidden = true;
			Application.current.window.backend.element.style.cursor = "none";
		}
	}

	public static function show():Void {
		if (__hidden) {
			__hidden = false;

			var cacheValue = __cursor;
			__cursor = null;
			set_cursor(cacheValue);
		}
	}

	static function get_cursor():MouseCursor {
		if (__cursor == null)
			return DEFAULT;
		return __cursor;
	}

	static function set_cursor(value:MouseCursor):MouseCursor {
		if (__cursor != value) {
			__cursor = value;
			if (!__hidden) {
				Application.current.window.backend.element.style.cursor = switch (value) {
					case ARROW: "default";
					case CROSSHAIR: "crosshair";
					case MOVE: "move";
					case POINTER: "pointer";
					case RESIZE_NESW: "nesw-resize";
					case RESIZE_NS: "ns-resize";
					case RESIZE_NWSE: "nwse-resize";
					case RESIZE_WE: "ew-resize";
					case TEXT: "text";
					case WAIT: "wait";
					case WAIT_ARROW: "wait";
					default: "auto";
				}
			}
		}
		return value;
	}
}
