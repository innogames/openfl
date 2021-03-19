package openfl.events;

class Event {
	public static inline final ACTIVATE:EventType<Event> = "activate";
	public static inline final ADDED:EventType<Event> = "added";
	public static inline final ADDED_TO_STAGE:EventType<Event> = "addedToStage";
	public static inline final CANCEL:EventType<Event> = "cancel";
	public static inline final CHANGE:EventType<Event> = "change";
	public static inline final CLEAR:EventType<Event> = "clear";
	public static inline final CLOSE:EventType<Event> = "close";
	public static inline final COMPLETE:EventType<Event> = "complete";
	public static inline final CONNECT:EventType<Event> = "connect";
	public static inline final CONTEXT3D_CREATE:EventType<Event> = "context3DCreate";
	public static inline final COPY:EventType<Event> = "copy";
	public static inline final CUT:EventType<Event> = "cut";
	public static inline final DEACTIVATE:EventType<Event> = "deactivate";
	public static inline final ENTER_FRAME:EventType<Event> = "enterFrame";
	public static inline final EXIT_FRAME:EventType<Event> = "exitFrame";
	public static inline final FRAME_CONSTRUCTED:EventType<Event> = "frameConstructed";
	public static inline final FRAME_LABEL:EventType<Event> = "frameLabel";
	public static inline final FULLSCREEN:EventType<Event> = "fullScreen";
	public static inline final ID3:EventType<Event> = "id3";
	public static inline final INIT:EventType<Event> = "init";
	public static inline final MOUSE_LEAVE:EventType<Event> = "mouseLeave";
	public static inline final OPEN:EventType<Event> = "open";
	public static inline final PASTE:EventType<Event> = "paste";
	public static inline final REMOVED:EventType<Event> = "removed";
	public static inline final REMOVED_FROM_STAGE:EventType<Event> = "removedFromStage";
	public static inline final RENDER:EventType<Event> = "render";
	public static inline final RESIZE:EventType<Event> = "resize";
	public static inline final SCROLL:EventType<Event> = "scroll";
	public static inline final SELECT:EventType<Event> = "select";
	public static inline final SELECT_ALL:EventType<Event> = "selectAll";
	public static inline final SOUND_COMPLETE:EventType<Event> = "soundComplete";
	public static inline final TAB_CHILDREN_CHANGE:EventType<Event> = "tabChildrenChange";
	public static inline final TAB_ENABLED_CHANGE:EventType<Event> = "tabEnabledChange";
	public static inline final TAB_INDEX_CHANGE:EventType<Event> = "tabIndexChange";
	public static inline final TEXTURE_READY:EventType<Event> = "textureReady";
	public static inline final UNLOAD:EventType<Event> = "unload";

	public var bubbles(default, null):Bool;
	public var cancelable(default, null):Bool;
	public var currentTarget(default, null):#if (haxe_ver >= "3.4.2") Any #else IEventDispatcher #end;
	public var eventPhase(default, null):EventPhase;
	public var target(default, null):#if (haxe_ver >= "3.4.2") Any #else IEventDispatcher #end;
	public var type(default, null):String;

	private var __isCanceled:Bool;
	private var __isCanceledNow:Bool;
	private var __preventDefault:Bool;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		eventPhase = EventPhase.AT_TARGET;
	}

	public function clone():Event {
		var event = new Event(type, bubbles, cancelable);
		event.eventPhase = eventPhase;
		event.target = target;
		event.currentTarget = currentTarget;
		return event;
	}

	public function formatToString(className:String, ?p1:String, ?p2:String, ?p3:String, ?p4:String, ?p5:String):String {
		var parameters = [];
		if (p1 != null)
			parameters.push(p1);
		if (p2 != null)
			parameters.push(p2);
		if (p3 != null)
			parameters.push(p3);
		if (p4 != null)
			parameters.push(p4);
		if (p5 != null)
			parameters.push(p5);

		return Reflect.callMethod(this, __formatToString, [className, parameters]);
	}

	public function isDefaultPrevented():Bool {
		return __preventDefault;
	}

	public function preventDefault():Void {
		if (cancelable) {
			__preventDefault = true;
		}
	}

	public function stopImmediatePropagation():Void {
		__isCanceled = true;
		__isCanceledNow = true;
	}

	public function stopPropagation():Void {
		__isCanceled = true;
	}

	public function toString():String {
		return __formatToString("Event", ["type", "bubbles", "cancelable"]);
	}

	private function __formatToString(className:String, parameters:Array<String>):String {
		// TODO: Make this a macro function, and handle at compile-time, with rest parameters?

		var output = '[$className';
		var arg:Dynamic = null;

		for (param in parameters) {
			arg = Reflect.field(this, param);

			if (Std.is(arg, String)) {
				output += ' $param="$arg"';
			} else {
				output += ' $param=$arg';
			}
		}

		output += "]";
		return output;
	}
}
