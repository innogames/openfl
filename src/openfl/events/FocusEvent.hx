package openfl.events;

import openfl.display.InteractiveObject;

class FocusEvent extends Event {
	public static inline var FOCUS_IN:EventType<FocusEvent> = "focusIn";
	public static inline var FOCUS_OUT:EventType<FocusEvent> = "focusOut";
	public static inline var KEY_FOCUS_CHANGE:EventType<FocusEvent> = "keyFocusChange";
	public static inline var MOUSE_FOCUS_CHANGE:EventType<FocusEvent> = "mouseFocusChange";

	public var keyCode:Int;
	public var relatedObject:InteractiveObject;
	public var shiftKey:Bool;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, relatedObject:InteractiveObject = null, shiftKey:Bool = false,
			keyCode:Int = 0) {
		super(type, bubbles, cancelable);

		this.keyCode = keyCode;
		this.shiftKey = shiftKey;
		this.relatedObject = relatedObject;
	}

	public override function clone():FocusEvent {
		var event = new FocusEvent(type, bubbles, cancelable, relatedObject, shiftKey, keyCode);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}

	public override function toString():String {
		return __formatToString("FocusEvent", ["type", "bubbles", "cancelable", "relatedObject", "shiftKey", "keyCode"]);
	}
}
