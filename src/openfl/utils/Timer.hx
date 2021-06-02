package openfl.utils;

import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;

class Timer extends EventDispatcher {
	public var currentCount(default, null):Int;
	public var delay(get, set):Float;
	public var repeatCount(get, set):Int;
	public var running(default, null):Bool;

	var __delay:Float;
	var __repeatCount:Int;
	var __interval:Interval;

	public function new(delay:Float, repeatCount:Int = 0):Void {
		if (Math.isNaN(delay) || delay < 0) {
			throw new Error("The delay specified is negative or not a finite number");
		}

		super();

		__delay = delay;
		__repeatCount = repeatCount;

		running = false;
		currentCount = 0;
	}

	public function reset():Void {
		if (running) {
			stop();
		}

		currentCount = 0;
	}

	public function start():Void {
		if (!running) {
			running = true;

			__interval = new Interval(timer_onTimer, __delay);
		}
	}

	public function stop():Void {
		running = false;

		if (__interval != null) {
			__interval.clear();
			__interval = null;
		}
	}

	// Getters & Setters

	private function get_delay():Float {
		return __delay;
	}

	private function set_delay(value:Float):Float {
		__delay = value;

		if (running) {
			stop();
			start();
		}

		return __delay;
	}

	private function get_repeatCount():Int {
		return __repeatCount;
	}

	private function set_repeatCount(v:Int):Int {
		if (running && v != 0 && v <= currentCount) {
			stop();
		}

		return __repeatCount = v;
	}

	// Event Handlers

	private function timer_onTimer():Void {
		currentCount++;

		if (__repeatCount > 0 && currentCount >= __repeatCount) {
			stop();
			dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
		} else {
			dispatchEvent(new TimerEvent(TimerEvent.TIMER));
		}
	}
}

#if hxnodejs
private abstract Interval(js.node.Timers.Timeout) {
	public inline function new(callback:()->Void, delay:Float) {
		this = js.node.Timers.setInterval(callback, Std.int(delay));
	}
	public inline function clear() {
		js.node.Timers.clearInterval(this);
	}
}
#else
private abstract Interval(Int) {
	public inline function new(callback:()->Void, delay:Float) {
		this = js.Browser.window.setInterval(callback, delay);
	}
	public inline function clear() {
		js.Browser.window.clearInterval(this);
	}
}
#end
