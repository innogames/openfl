package openfl.events;

abstract EventType<T:Event>(String) from String to String {
	@:op(A == B) static extern inline function equals<T:Event>(a:EventType<T>, b:String):Bool {
		return (a : String) == b;
	}

	@:op(A != B) static extern inline function notEquals<T:Event>(a:EventType<T>, b:String):Bool {
		return (a : String) != b;
	}
}
