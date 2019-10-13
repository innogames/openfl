package lime.system;


import lime.app.Application;
import lime.app.Event;

#if flash
import flash.desktop.Clipboard in FlashClipboard;
#elseif (js && html5)
import lime._backend.html5.HTML5Window;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime.ui.Window)


class Clipboard {
	
	
	public static var onUpdate = new Event<Void->Void> ();
	public static var text (get, set):String;
	
	private static var _text:String;
	
	
	
	private static function __update ():Void {
		
		var cacheText = _text;
		
		if (_text != cacheText) {
			
			onUpdate.dispatch ();
			
		}
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private static function get_text ():String {
		
		#if flash
		__update ();
		#end
		
		return _text;
		
	}
	
	
	private static inline function set_text (value:String):String {
		
		setText (value, true);
		
		return value;
		
	}
	
	
	public static function setText (value:String, syncSystemClipboard:Bool) {
		
		var cacheText = _text;
		_text = value;
		
		if (syncSystemClipboard) {
			
			#if (js && html5)
			var window = Application.current.window;
			if (window != null) {
				
				window.backend.setClipboard (value);
				
			}
			#end
			
		}
		
		if (_text != cacheText) {
			
			onUpdate.dispatch ();
			
		}
		
	}
	
	
}