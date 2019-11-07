package openfl.events;


import openfl.events.Event;

class ActivityEvent extends Event {
	
	
	public static inline var ACTIVITY:EventName<ActivityEvent> = "activity";
	
	public var activating:Bool;
	
	
	public function new (type:EventName<ActivityEvent>, bubbles:Bool = false, cancelable:Bool = false, activating:Bool = false) {
		
		super (type, bubbles, cancelable);
		
		this.activating = activating;
		
	}
	
	
	public override function clone ():Event {
		
		var event = new ActivityEvent (type, bubbles, cancelable, activating);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
		
	}
	
	
	public override function toString ():String {
		
		return __formatToString ("ActivityEvent",  [ "type", "bubbles", "cancelable", "activating" ]);
		
	}
	
	
}