package openfl;


import js.Browser;
import haxe.Constraints.Function;
import haxe.Timer;
import openfl._internal.Lib in InternalLib;
import openfl.display.Application;
import openfl.display.MovieClip;
import openfl.net.URLLoader;
import openfl.net.URLRequest;


@:access(openfl.display.Stage) class Lib {
	
	
	public static var application (get, never):Application;
	public static var current (get, never):MovieClip;
	
	private static var __lastTimerID:UInt = 0;
	private static var __timers = new Map<UInt, Timer> ();
	
	
	public static /* inline */ function as<T> (v:Dynamic, c:Class<T>):Null<T> {
		
		return Std.is (v, c) ? v : null;
		
	}
	
	
	public static function clearInterval (id:UInt):Void {
		
		if (__timers.exists (id)) {
			
			var timer = __timers[id];
			timer.stop ();
			__timers.remove (id);
			
		}
		
	}
	
	
	public static function clearTimeout (id:UInt):Void {
		
		if (__timers.exists (id)) {
			
			var timer = __timers[id];
			timer.stop ();
			__timers.remove (id);
			
		}
		
	}
	
	
	public static function getDefinitionByName (name:String):Class<Dynamic> {
		
		return Type.resolveClass (name);
		
	}
	
	
	public static function getQualifiedClassName (value:Dynamic):String {
		
		return Type.getClassName (Type.getClass (value));
		
	}
	
	
	public static function getQualifiedSuperclassName (value:Dynamic):String {
		
		var ref = Type.getSuperClass (Type.getClass (value));
		return (ref != null ? Type.getClassName (ref) : null);
		
	}
	
	
	public static function getTimer ():Int {
		
		return Std.int (Browser.window.performance.now ());
		
	}
	
	
	public static function getURL (request:URLRequest, target:String = null):Void {
		
		navigateToURL (request, target);
		
	}
	
	
	public static function navigateToURL (request:URLRequest, window:String = null):Void {
		
		if (window == null) {
			
			window = "_blank";
			
		}
		
		var uri = request.url;
		
		if (Type.typeof(request.data) == TObject) {
			
			var query = "";
			var fields = Reflect.fields (request.data);
			
			for (field in fields) {
				
				if (query.length > 0) query += "&";
				query += StringTools.urlEncode (field) + "=" + StringTools.urlEncode (Std.string (Reflect.field (request.data, field)));
				
			}
			
			if (uri.indexOf ("?") > -1) {
				
				uri += "&" + query;
				
			} else {
				
				uri += "?" + query;
				
			}
			
		}
		
		Browser.window.open (uri, window);
		
	}
	
	
	public static function preventDefaultTouchMove ():Void {
		
		Browser.document.addEventListener ("touchmove", function (evt:js.html.Event):Void {
			
			evt.preventDefault ();
			
		}, false);
		
	}
	
	
	public static function sendToURL (request:URLRequest):Void {
		
		var urlLoader = new URLLoader ();
		urlLoader.load (request);
		
	}
	
	
	public static function setInterval (closure:Function, delay:Int, args:Array<Dynamic>):UInt {
		
		var id = ++__lastTimerID;
		var timer = new Timer (delay);
		__timers[id] = timer;
		timer.run = function () {
			
			Reflect.callMethod (closure, closure, args);
			
		};
		return id;
		
	}
	
	
	public static function setTimeout (closure:Function, delay:Int, args:Array<Dynamic>):UInt {
		
		var id = ++__lastTimerID;
		__timers[id] = Timer.delay (function () {
			
			Reflect.callMethod (closure, closure, args);
			
		}, delay);
		return id;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	static inline function get_application ():Application {
		
		return Application.current;
		
	}
	
	
	static function get_current ():MovieClip {
		
		if (InternalLib.current == null) InternalLib.current = new MovieClip ();
		return InternalLib.current;
		
	}
	
	
}