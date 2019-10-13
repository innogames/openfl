package lime.system;


import haxe.Constraints;

import lime.app.Application;
import lime.app.Config;
import lime.math.Rectangle;
import lime.utils.ArrayBuffer;
import lime.utils.UInt8Array;
import lime.utils.UInt16Array;

#if (js && html5)
import js.html.Element;
import js.Browser;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

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
	
	@:noCompletion private static var __applicationConfig:Map<String, Config>;
	@:noCompletion private static var __applicationDirectory:String;
	@:noCompletion private static var __applicationEntryPoint:Map<String, Function>;
	@:noCompletion private static var __applicationStorageDirectory:String;
	@:noCompletion private static var __desktopDirectory:String;
	@:noCompletion private static var __deviceModel:String;
	@:noCompletion private static var __deviceVendor:String;
	@:noCompletion private static var __documentsDirectory:String;
	@:noCompletion private static var __endianness:Endian;
	@:noCompletion private static var __fontsDirectory:String;
	@:noCompletion private static var __platformLabel:String;
	@:noCompletion private static var __platformName:String;
	@:noCompletion private static var __platformVersion:String;
	@:noCompletion private static var __userDirectory:String;
	
	
	#if (js && html5)
	@:keep @:expose("lime.embed")
	public static function embed (projectName:String, element:Dynamic, width:Null<Int> = null, height:Null<Int> = null, windowConfig:Dynamic = null):Void {
		
		if (__applicationEntryPoint == null || __applicationConfig == null) return;
		
		if (__applicationEntryPoint.exists (projectName)) {
			
			var htmlElement:Element = null;
			
			if (Std.is (element, String)) {
				
				htmlElement = cast Browser.document.getElementById (element);
				
			} else if (element == null) {
				
				htmlElement = cast Browser.document.createElement ("div");
				
			} else {
				
				htmlElement = cast element;
				
			}
			
			if (htmlElement == null) {
				
				Browser.window.console.log ("[lime.embed] ERROR: Cannot find target element: " + element);
				return;
				
			}
			
			if (width == null) {
				
				width = 0;
				
			}
			
			if (height == null) {
				
				height = 0;
				
			}
			
			var defaultConfig = __applicationConfig[projectName];
			var config:Config = {};
			
			__copyMissingFields (config, defaultConfig);
			
			if (windowConfig != null) {
				
				config.windows = [];
				
				if (Std.is (windowConfig, Array)) {
					
					config.windows = windowConfig;
					
				} else {
					
					config.windows[0] = windowConfig;
					
				}
				
				for (i in 0...config.windows.length) {
					
					if (i < defaultConfig.windows.length) {
						
						__copyMissingFields (config.windows[i], defaultConfig.windows[i]);
						
					}
					
					__copyMissingFields (config.windows[i].parameters, defaultConfig.windows[i].parameters);
					
					if (Std.is (windowConfig.background, String)) {
						
						var background = StringTools.replace (Std.string (windowConfig.background), "#", "");
						
						if (background.indexOf ("0x") > -1) {
							
							windowConfig.background = Std.parseInt (background);
							
						} else {
							
							windowConfig.background = Std.parseInt ("0x" + background);
							
						}
						
					}
					
				}
				
			}
			
			if (Reflect.field (config.windows[0], "rootPath")) {
				
				config.rootPath = Reflect.field (config.windows[0], "rootPath");
				Reflect.deleteField (config.windows[0], "rootPath");
				
			}
			
			config.windows[0].element = htmlElement;
			config.windows[0].width = width;
			config.windows[0].height = height;
			
			__applicationEntryPoint[projectName] (config);
			
		}
		
	}
	#end
	
	
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
	
	
	public static function getDisplay (id:Int):Display {
		
		#if html5
		if (id == 0) {
			
			var display = new Display ();
			display.id = 0;
			display.name = "Generic Display";
			
			//var div = Browser.document.createElement ("div");
			//div.style.width = "1in";
			//Browser.document.body.appendChild (div);
			//var ppi = Browser.document.defaultView.getComputedStyle (div, null).getPropertyValue ("width");
			//Browser.document.body.removeChild (div);
			//display.dpi = Std.parseFloat (ppi);
			display.dpi = 96 * Browser.window.devicePixelRatio;
			display.currentMode = new DisplayMode (Browser.window.screen.width, Browser.window.screen.height, 60, ARGB32);
			
			display.supportedModes = [ display.currentMode ];
			display.bounds = new Rectangle (0, 0, display.currentMode.width, display.currentMode.height);
			return display;
			
		}
		#end
		
		return null;
		
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
	
	
	@:noCompletion private static function __copyMissingFields (target:Dynamic, source:Dynamic):Void {
		
		if (source == null || target == null) return;
		
		for (field in Reflect.fields (source)) {
			
			if (!Reflect.hasField (target, field)) {
				
				Reflect.setField (target, field, Reflect.field (source, field));
				
			}
			
		}
		
	}
	
	
	@:noCompletion private static function __registerEntryPoint (projectName:String, entryPoint:Function, config:Config):Void {
		
		if (__applicationConfig == null) {
			
			__applicationConfig = new Map ();
			
		}
		
		if (__applicationEntryPoint == null) {
			
			__applicationEntryPoint = new Map ();
			
		}
		
		__applicationEntryPoint[projectName] = entryPoint;
		__applicationConfig[projectName] = config;
		
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
