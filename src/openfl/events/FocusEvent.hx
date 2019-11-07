package openfl.events;


import openfl.display.InteractiveObject;
import openfl.events.Event;

class FocusEvent extends Event {
	
	
	public static inline var FOCUS_IN:EventName<FocusEvent> = "focusIn";
	public static inline var FOCUS_OUT:EventName<FocusEvent> = "focusOut";
	public static inline var KEY_FOCUS_CHANGE:EventName<FocusEvent> = "keyFocusChange";
	public static inline var MOUSE_FOCUS_CHANGE:EventName<FocusEvent> = "mouseFocusChange";
	
	public var keyCode:Int;
	public var relatedObject:InteractiveObject;
	public var shiftKey:Bool;
	
	
	public function new (type:EventName<FocusEvent>, bubbles:Bool = false, cancelable:Bool = false, relatedObject:InteractiveObject = null, shiftKey:Bool = false, keyCode:Int = 0) {
		
		super (type, bubbles, cancelable);
		
		this.keyCode = keyCode;
		this.shiftKey = shiftKey;
		this.relatedObject = relatedObject;
		
	}
	
	
	public override function clone ():Event {
		
		var event = new FocusEvent (type, bubbles, cancelable, relatedObject, shiftKey, keyCode);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
		
	}
	
	
	public override function toString ():String {
		
		return __formatToString ("FocusEvent",  [ "type", "bubbles", "cancelable", "relatedObject", "shiftKey", "keyCode" ]);
		
	}
	
	
}