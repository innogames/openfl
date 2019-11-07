package openfl.events;


class Event {
	
	public static inline var ACTIVATE:EventName<Event> = "activate";
	public static inline var ADDED:EventName<Event> = "added";
	public static inline var ADDED_TO_STAGE:EventName<Event> = "addedToStage";
	public static inline var CANCEL:EventName<Event> = "cancel";
	public static inline var CHANGE:EventName<Event> = "change";
	public static inline var CLEAR:EventName<Event> = "clear";
	public static inline var CLOSE:EventName<Event> = "close";
	public static inline var COMPLETE:EventName<Event> = "complete";
	public static inline var CONNECT:EventName<Event> = "connect";
	public static inline var CONTEXT3D_CREATE:EventName<Event> = "context3DCreate";
	public static inline var COPY:EventName<Event> = "copy";
	public static inline var CUT:EventName<Event> = "cut";
	public static inline var DEACTIVATE:EventName<Event> = "deactivate";
	public static inline var ENTER_FRAME:EventName<Event> = "enterFrame";
	public static inline var EXIT_FRAME:EventName<Event> = "exitFrame";
	public static inline var FRAME_CONSTRUCTED:EventName<Event> = "frameConstructed";
	public static inline var FRAME_LABEL:EventName<Event> = "frameLabel";
	public static inline var FULLSCREEN:EventName<Event> = "fullScreen";
	public static inline var ID3:EventName<Event> = "id3";
	public static inline var INIT:EventName<Event> = "init";
	public static inline var MOUSE_LEAVE:EventName<Event> = "mouseLeave";
	public static inline var OPEN:EventName<Event> = "open";
	public static inline var PASTE:EventName<Event> = "paste";
	public static inline var REMOVED:EventName<Event> = "removed";
	public static inline var REMOVED_FROM_STAGE:EventName<Event> = "removedFromStage";
	public static inline var RENDER:EventName<Event> = "render";
	public static inline var RESIZE:EventName<Event> = "resize";
	public static inline var SCROLL:EventName<Event> = "scroll";
	public static inline var SELECT:EventName<Event> = "select";
	public static inline var SELECT_ALL:EventName<Event> = "selectAll";
	public static inline var SOUND_COMPLETE:EventName<Event> = "soundComplete";
	public static inline var TAB_CHILDREN_CHANGE:EventName<Event> = "tabChildrenChange";
	public static inline var TAB_ENABLED_CHANGE:EventName<Event> = "tabEnabledChange";
	public static inline var TAB_INDEX_CHANGE:EventName<Event> = "tabIndexChange";
	public static inline var TEXTURE_READY:EventName<Event> = "textureReady";
	public static inline var UNLOAD:EventName<Event> = "unload";
	
	public var bubbles (default, null):Bool;
	public var cancelable (default, null):Bool;
	public var currentTarget (default, null):#if (haxe_ver >= "3.4.2") Any #else IEventDispatcher #end;
	public var eventPhase (default, null):EventPhase;
	public var target (default, null):#if (haxe_ver >= "3.4.2") Any #else IEventDispatcher #end;
	public var type (default, null):String;
	
	private var __isCanceled:Bool;
	private var __isCanceledNow:Bool;
	private var __preventDefault:Bool;
	
	
	public function new (type:String, bubbles:Bool = false, cancelable:Bool = false) {
		
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		eventPhase = EventPhase.AT_TARGET;
		
	}
	
	
	public function clone ():Event {
		
		var event = new Event (type, bubbles, cancelable);
		event.eventPhase = eventPhase;
		event.target = target;
		event.currentTarget = currentTarget;
		return event;
		
	}
	
	
	public function formatToString (className:String, ?p1:String, ?p2:String, ?p3:String, ?p4:String, ?p5:String):String {
		
		var parameters = [];
		if (p1 != null) parameters.push (p1);
		if (p2 != null) parameters.push (p2);
		if (p3 != null) parameters.push (p3);
		if (p4 != null) parameters.push (p4);
		if (p5 != null) parameters.push (p5);
		
		return Reflect.callMethod (this, __formatToString, [ className, parameters ]);
		
	}
	
	
	public function isDefaultPrevented ():Bool {
		
		return __preventDefault;
		
	}
	
	
	public function preventDefault ():Void {
		
		if (cancelable) {
			
			__preventDefault = true;
			
		}
		
	}
	
	
	public function stopImmediatePropagation ():Void {
		
		__isCanceled = true;
		__isCanceledNow = true;
		
	}
	
	
	public function stopPropagation ():Void {
		
		__isCanceled = true;
		
	}
	
	
	public function toString ():String {
		
		return __formatToString ("Event",  [ "type", "bubbles", "cancelable" ]);
		
	}
	
	
	private function __formatToString (className:String, parameters:Array<String>):String {
		
		// TODO: Make this a macro function, and handle at compile-time, with rest parameters?
		
		var output = '[$className';
		var arg:Dynamic = null;
		
		for (param in parameters) {
			
			arg = Reflect.field (this, param);
			
			if (Std.is (arg, String)) {
				
				output += ' $param="$arg"';
				
			} else {
				
				output += ' $param=$arg';
				
			}
			
		}
		
		output += "]";
		return output;
		
	}
	
	
}

abstract EventName<T:Event>(String) from String to String {}
