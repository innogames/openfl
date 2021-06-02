package openfl.events;

class AccelerometerEvent extends Event {
	public static inline var UPDATE:EventType<AccelerometerEvent> = "update";

	public var accelerationX:Float;
	public var accelerationY:Float;
	public var accelerationZ:Float;
	public var timestamp:Float;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, timestamp:Float = 0, accelerationX:Float = 0, accelerationY:Float = 0,
			accelerationZ:Float = 0):Void {
		super(type, bubbles, cancelable);

		this.timestamp = timestamp;
		this.accelerationX = accelerationX;
		this.accelerationY = accelerationY;
		this.accelerationZ = accelerationZ;
	}

	public override function clone():AccelerometerEvent {
		var event = new AccelerometerEvent(type, bubbles, cancelable, timestamp, accelerationX, accelerationY, accelerationZ);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
	}

	public override function toString():String {
		return __formatToString("AccelerometerEvent", [
			"type",
			"bubbles",
			"cancelable",
			"timestamp",
			"accelerationX",
			"accelerationY",
			"accelerationZ"
		]);
	}
}
