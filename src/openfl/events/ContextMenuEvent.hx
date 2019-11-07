package openfl.events;


import openfl.display.InteractiveObject;
import openfl.events.Event;

class ContextMenuEvent extends Event {
	
	
	public static inline var MENU_ITEM_SELECT:EventName<ContextMenuEvent> = "menuItemSelect";
	public static inline var MENU_SELECT:EventName<ContextMenuEvent> = "menuSelect";
	
	public var contextMenuOwner:InteractiveObject;
	public var mouseTarget:InteractiveObject;
	
	
	public function new (type:EventName<ContextMenuEvent>, bubbles:Bool = false, cancelable:Bool = false, mouseTarget:InteractiveObject = null, contextMenuOwner:InteractiveObject = null) {
		
		super (type, bubbles, cancelable);
		
		this.mouseTarget = mouseTarget;
		this.contextMenuOwner = contextMenuOwner;
		
	}
	
	
	public override function clone ():Event {
		
		var event = new ContextMenuEvent (type, bubbles, cancelable, mouseTarget, contextMenuOwner);
		event.target = target;
		event.currentTarget = currentTarget;
		event.eventPhase = eventPhase;
		return event;
		
	}
	
	
	public override function toString ():String {
		
		return __formatToString ("ContextMenuEvent",  [ "type", "bubbles", "cancelable", "mouseTarget", "contextMenuOwner" ]);
		
	}
	
	
}