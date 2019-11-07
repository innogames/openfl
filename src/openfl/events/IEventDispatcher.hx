package openfl.events;

import openfl.events.Event;

interface IEventDispatcher {
	
	public function addEventListener<T:Event> (type:EventName<T>, listener:T->Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void;
	public function dispatchEvent (event:Event):Bool;
	public function hasEventListener (type:String):Bool;
	public function removeEventListener<T:Event> (type:EventName<T>, listener:T->Void, useCapture:Bool = false):Void;
	public function willTrigger (type:String):Bool;
	
}