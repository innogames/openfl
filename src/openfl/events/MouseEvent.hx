package openfl.events;


import openfl.display.InteractiveObject;
import openfl.geom.Point;
import openfl.events.Event;


class MouseEvent extends Event {
	
	
	public static inline var CLICK:EventName<MouseEvent> = "click";
	public static inline var DOUBLE_CLICK:EventName<MouseEvent> = "doubleClick";
	public static inline var MIDDLE_CLICK:EventName<MouseEvent> = "middleClick";
	public static inline var MIDDLE_MOUSE_DOWN:EventName<MouseEvent> = "middleMouseDown";
	public static inline var MIDDLE_MOUSE_UP:EventName<MouseEvent> = "middleMouseUp";
	public static inline var MOUSE_DOWN:EventName<MouseEvent> = "mouseDown";
	public static inline var MOUSE_MOVE:EventName<MouseEvent> = "mouseMove";
	public static inline var MOUSE_OUT:EventName<MouseEvent> = "mouseOut";
	public static inline var MOUSE_OVER:EventName<MouseEvent> = "mouseOver";
	public static inline var MOUSE_UP:EventName<MouseEvent> = "mouseUp";
	public static inline var MOUSE_WHEEL:EventName<MouseEvent> = "mouseWheel";
	public static inline var RELEASE_OUTSIDE:EventName<MouseEvent> = "releaseOutside";
	public static inline var RIGHT_CLICK:EventName<MouseEvent> = "rightClick";
	public static inline var RIGHT_MOUSE_DOWN:EventName<MouseEvent> = "rightMouseDown";
	public static inline var RIGHT_MOUSE_UP:EventName<MouseEvent> = "rightMouseUp";
	public static inline var ROLL_OUT:EventName<MouseEvent> = "rollOut";
	public static inline var ROLL_OVER:EventName<MouseEvent> = "rollOver";
	
	private static var __altKey:Bool;
	private static var __buttonDown:Bool;
	private static var __commandKey:Bool;
	private static var __ctrlKey:Bool;
	private static var __shiftKey:Bool;
	
	public var altKey:Bool;
	public var buttonDown:Bool;
	public var commandKey:Bool;
	public var clickCount:Int;
	public var ctrlKey:Bool;
	public var delta:Int;
	public var isRelatedObjectInaccessible:Bool;
	public var localX:Float;
	public var localY:Float;
	public var relatedObject:InteractiveObject;
	public var shiftKey:Bool;
	public var stageX:Float;
	public var stageY:Float;
	
	
	public function new (type:EventName<MouseEvent>, bubbles:Bool = true, cancelable:Bool = false, localX:Float = 0, localY:Float = 0, relatedObject:InteractiveObject = null, ctrlKey:Bool = false, altKey:Bool = false, shiftKey:Bool = false, buttonDown:Bool = false, delta:Int = 0, commandKey:Bool = false, clickCount:Int = 0) {
		
		super (type, bubbles, cancelable);
		
		this.shiftKey = shiftKey;
		this.altKey = altKey;
		this.ctrlKey = ctrlKey;
		this.bubbles = bubbles;
		this.relatedObject = relatedObject;
		this.delta = delta;
		this.localX = localX;
		this.localY = localY;
		this.buttonDown = buttonDown;
		this.commandKey = commandKey;
		this.clickCount = clickCount;
		
		isRelatedObjectInaccessible = false;
		stageX = Math.NaN;
		stageY = Math.NaN;
		
	}
	
	
	public static function __create (type:String, button:Int, stageX:Float, stageY:Float, local:Point, target:InteractiveObject, delta:Int = 0):MouseEvent {
		
		var event = new MouseEvent (type, true, false, local.x, local.y, null, __ctrlKey, __altKey, __shiftKey, __buttonDown, delta, __commandKey);
		event.stageX = stageX;
		event.stageY = stageY;
		event.target = target;
		
		return event;
		
	}
	
	
	public override function clone ():Event {
		
		var event = new MouseEvent (type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta, commandKey, clickCount);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
		
	}
	
	
	public override function toString ():String {
		
		return __formatToString ("MouseEvent",  [ "type", "bubbles", "cancelable", "localX", "localY", "relatedObject", "ctrlKey", "altKey", "shiftKey", "buttonDown", "delta" ]);
		
	}
	
	
	public function updateAfterEvent ():Void {
		
		
		
	}
	
	
}