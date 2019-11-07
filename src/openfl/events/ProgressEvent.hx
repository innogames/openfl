package openfl.events;

import openfl.events.Event;

class ProgressEvent extends Event {
	
	
	public static inline var PROGRESS:EventName<ProgressEvent> = "progress";
	public static inline var SOCKET_DATA:EventName<ProgressEvent> = "socketData";
	
	public var bytesLoaded:Float;
	public var bytesTotal:Float;
	
	
	public function new (type:EventName<ProgressEvent>, bubbles:Bool = false, cancelable:Bool = false, bytesLoaded:Float = 0, bytesTotal:Float = 0) {
		
		super (type, bubbles, cancelable);
		
		this.bytesLoaded = bytesLoaded;
		this.bytesTotal = bytesTotal;
		
	}
	
	
	public override function clone ():Event {
		
		var event = new ProgressEvent (type, bubbles, cancelable, bytesLoaded, bytesTotal);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
		
	}
	
	
	public override function toString ():String {
		
		return __formatToString ("ProgressEvent",  [ "type", "bubbles", "cancelable", "bytesLoaded", "bytesTotal" ]);
		
	}
	
	
}