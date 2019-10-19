package lime.system;

import js.Browser;

import lime.utils.ArrayBuffer;
import lime.utils.UInt8Array;
import lime.utils.UInt16Array;

@:access(lime.system.Display)
@:access(lime.system.DisplayMode)
class System {
	
	
	public static var allowScreenTimeout (get, set):Bool;
	public static var applicationDirectory (get, never):String;
	public static var applicationStorageDirectory (get, never):String;
	public static var desktopDirectory (get, never):String;
	public static var deviceModel (get, never):String;
	public static var deviceVendor (get, never):String;
	public static var documentsDirectory (get, never):String;
	public static var endianness (get, never):Endian;
	public static var fontsDirectory (get, never):String;
	public static var numDisplays (get, never):Int;
	public static var platformLabel (get, never):String;
	public static var platformName (get, never):String;
	public static var platformVersion (get, never):String;
	public static var userDirectory (get, never):String;
	
	static var __applicationDirectory:String;
	static var __applicationStorageDirectory:String;
	static var __desktopDirectory:String;
	static var __deviceModel:String;
	static var __deviceVendor:String;
	static var __documentsDirectory:String;
	static var __endianness:Endian;
	static var __fontsDirectory:String;
	static var __platformLabel:String;
	static var __platformName:String;
	static var __platformVersion:String;
	static var __userDirectory:String;
	
	
	public static function exit (code:Int):Void {
		
		#if ((sys || air) && !macro)
		if (Application.current != null) {
			
			Application.current.onExit.dispatch (code);
			
			if (Application.current.onExit.canceled) {
				
				return;
				
			}
			
		}
		#end
		
		#if sys
		Sys.exit (code);
		#elseif air
		NativeApplication.nativeApplication.exit (code);
		#end
		
	}
	
	
	public static function getTimer ():Int {
		
		#if flash
		return flash.Lib.getTimer ();
		#elseif (js && !nodejs)
		return Std.int (Browser.window.performance.now ());
		#elseif cpp
		return Std.int (untyped __global__.__time_stamp () * 1000);
		#elseif sys
		return Std.int (Sys.time () * 1000);
		#else
		return 0;
		#end
		
	}
	
	

	public static function openFile (path:String):Void {
		
		if (path != null) {
			
			#if (js && html5)
			
			Browser.window.open (path, "_blank");
			
			#end
			
		}
		
	}
	
	
	public static function openURL (url:String, target:String = "_blank"):Void {
		
		if (url != null) {
			
			#if (js && html5)
			
			Browser.window.open (url, target);
			
			#end
			
		}
		
	}
	
	
	// Get & Set Methods
	
	
	
	
	private static function get_allowScreenTimeout ():Bool {
		
		return true;
		
	}
	
	
	private static function set_allowScreenTimeout (value:Bool):Bool {
		
		return true;
		
	}
	
	
	private static function get_applicationDirectory ():String {
		
		return __applicationDirectory;
		
	}
	
	
	private static function get_applicationStorageDirectory ():String {
		
		return __applicationStorageDirectory;
		
	}
	
	
	private static function get_deviceModel ():String {
		
		return __deviceModel;
		
	}
	
	
	private static function get_deviceVendor ():String {
		
		return __deviceVendor;
		
	}
	
	
	private static function get_desktopDirectory ():String {
		
		return __desktopDirectory;
		
	}
	
	
	private static function get_documentsDirectory ():String {
		
		return __documentsDirectory;
		
	}
	
	
	private static function get_endianness ():Endian {
		
		if (__endianness == null) {
			
			var arrayBuffer = new ArrayBuffer (2);
			var uint8Array = new UInt8Array (arrayBuffer);
			var uint16array = new UInt16Array (arrayBuffer);
			uint8Array[0] = 0xAA;
			uint8Array[1] = 0xBB;
			if (uint16array[0] == 0xAABB) __endianness = BIG_ENDIAN;
			else __endianness = LITTLE_ENDIAN;
			
		}
		
		return __endianness;
		
	}
	
	
	private static function get_fontsDirectory ():String {
		
		return __fontsDirectory;
		
	}
	
	
	private static function get_numDisplays ():Int {
		
		return 1;
		
	}
	
	
	private static function get_platformLabel ():String {
		
		if (__platformLabel == null) {
			
			var name = System.platformName;
			var version = System.platformVersion;
			if (name != null && version != null) __platformLabel = name + " " + version;
			else if (name != null) __platformLabel = name;
			
		}
		
		return __platformLabel;
		
	}
	
	
	private static function get_platformName ():String {
		
		if (__platformName == null) {
			
			__platformName = "HTML5";
			
		}
		
		return __platformName;
		
	}
	
	
	private static function get_platformVersion ():String {
		
		return __platformVersion;
		
	}
	
	
	private static function get_userDirectory ():String {
		
		return __userDirectory;
		
	}
	
	
}
