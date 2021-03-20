package openfl.events;

class UncaughtErrorEvents extends EventDispatcher {
	// we don't support different application domains, so there's only a single instance
	public static final instance = new UncaughtErrorEvents();

	function new() {
		super();
	}

	override function addEventListener<T:Event>(type:EventType<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false) {
		if (type == UncaughtErrorEvent.UNCAUGHT_ERROR && !hasEventListener(type)) {
			js.Browser.window.addEventListener("error", __jsListener);
		}
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	override function removeEventListener<T:Event>(type:EventType<T>, listener:T->Void, useCapture:Bool = false) {
		super.removeEventListener(type, listener, useCapture);
		if (type == UncaughtErrorEvent.UNCAUGHT_ERROR && !hasEventListener(type)) {
			js.Browser.window.removeEventListener("error", __jsListener);
		}
	}

	function __jsListener(e:js.html.ErrorEvent) {
		var error:Any = e.error;
		if (error == null) {
			error = 'Uncaught JS error: message=`${e.message}`, position=`${e.filename}:${e.lineno}:${e.colno}`';
		}
		var event = new UncaughtErrorEvent(UncaughtErrorEvent.UNCAUGHT_ERROR, true, true, error);
		dispatchEvent(event);
		if (event.isDefaultPrevented()) {
			e.preventDefault();
		}
	}
}
