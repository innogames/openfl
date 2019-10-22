package openfl.net;


import js.Browser;
import haxe.io.Bytes;
import haxe.Serializer;
import haxe.Unserializer;
import lime.app.Application;
import openfl._internal.Lib;
import openfl.errors.Error;
import openfl.events.EventDispatcher;
import openfl.net.SharedObjectFlushStatus;
import openfl.utils.Object;


class SharedObject extends EventDispatcher {
	
	
	public static var defaultObjectEncoding:Int = 3;
	
	private static var __sharedObjects:Map<String, SharedObject>;
	
	
	public var client:Dynamic;
	public var data (default, null):Dynamic;
	public var fps (null, default):Float;
	public var objectEncoding:Int;
	public var size (get, never):Int;
	
	private var __localPath:String;
	private var __name:String;
	
	
	private function new () {
		
		super ();
		
		client = this;
		objectEncoding = 3;
		
	}
	
	
	public function clear ():Void {
		
		data = {};
		
		try {
			
			var storage = Browser.getLocalStorage ();
			
			if (storage != null) {
				
				storage.removeItem (__localPath + ":" + __name);
				
			}
			
		} catch (e:Dynamic) {}
		
	}
	
	
	public function close ():Void {
		
		
		
	}
	
	
	public function connect (myConnection:NetConnection, params:String = null):Void {
		
		openfl._internal.Lib.notImplemented ();
		
	}
	
	
	public function flush (minDiskSpace:Int = 0):SharedObjectFlushStatus {
		
		if (Reflect.fields (data).length == 0) {
			
			return SharedObjectFlushStatus.FLUSHED;
			
		}
		
		var encodedData = Serializer.run (data);
		
		try {
			
			var storage = Browser.getLocalStorage ();
			
			if (storage != null) {
				
				storage.removeItem (__localPath + ":" + __name);
				storage.setItem (__localPath + ":" + __name, encodedData);
				
			}
			
		} catch (e:Dynamic) {
			
			return SharedObjectFlushStatus.PENDING;
			
		}
		
		return SharedObjectFlushStatus.FLUSHED;
		
	}
	
	
	public static function getLocal (name:String, localPath:String = null, secure:Bool = false /* note: unsupported */):SharedObject {
		
		var illegalValues = [ " ", "~", "%", "&", "\\", ";", ":", "\"", "'", ",", "<", ">", "?", "#" ];
		var allowed = true;
		
		if (name == null || name == "") {
			
			allowed = false;
			
		} else {
			
			for (value in illegalValues) {
				
				if (name.indexOf (value) > -1) {
					
					allowed = false;
					break;
					
				}
				
			}
			
		}
		
		if (!allowed) {
			
			throw new Error ("Error #2134: Cannot create SharedObject.");
			return null;
			
		}
		
		if (localPath == null) {
			
			localPath = Browser.window.location.href;
			
		}
		
		if (__sharedObjects == null) {
			
			__sharedObjects = new Map ();
			// Lib.application.onExit.add (application_onExit);
			if (Application.current != null) {
				
				Application.current.onExit.add (application_onExit);
				
			}
			
		}
		
		var id = localPath + "/" + name;
		
		if (!__sharedObjects.exists (id)) {
			
			var sharedObject = new SharedObject ();
			sharedObject.data = {};
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;
			
			var encodedData = null;
			
			try {
				
				var storage = Browser.getLocalStorage ();
				
				if (storage != null) {
					
					encodedData = storage.getItem (localPath + ":" + name);
					
				}
				
			} catch (e:Dynamic) { }
			
			if (encodedData != null && encodedData != "") {
				
				try {
					
					var unserializer = new Unserializer (encodedData);
					unserializer.setResolver (cast { resolveEnum: Type.resolveEnum, resolveClass: __resolveClass } );
					sharedObject.data = unserializer.unserialize ();
					
				} catch (e:Dynamic) {}
				
			}
			
			__sharedObjects.set (id, sharedObject);
			
		}
		
		return __sharedObjects.get (id);
		
	}
	
	
	public static function getRemote (name:String, remotePath:String = null, persistence:Dynamic = false, secure:Bool = false):SharedObject {
		
		openfl._internal.Lib.notImplemented ();
		
		return null;
		
	}
	
	
	public function send (args:Array<Dynamic>):Void {
		
		openfl._internal.Lib.notImplemented ();
		
	}
	
	
	public function setDirty (propertyName:String):Void {
		
		
		
	}
	
	
	public function setProperty (propertyName:String, value:Object = null):Void {
		
		if (data != null) {
			
			Reflect.setField (data, propertyName, value);
			
		}
		
	}
	
	
	private static function __resolveClass (name:String):Class<Dynamic> {
		
		if (name != null) {
			
			if (StringTools.startsWith (name, "neash.")) {
				
				name = StringTools.replace (name, "neash.", "openfl.");
				
			}
			
			if (StringTools.startsWith (name, "native.")) {
				
				name = StringTools.replace (name, "native.", "openfl.");
				
			}
			
			if (StringTools.startsWith (name, "flash.")) {
				
				name = StringTools.replace (name, "flash.", "openfl.");
				
			}
			
			if (StringTools.startsWith (name, "openfl._v2.")) {
				
				name = StringTools.replace (name, "openfl._v2.", "openfl.");
				
			}
			
			if (StringTools.startsWith (name, "openfl._legacy.")) {
				
				name = StringTools.replace (name, "openfl._legacy.", "openfl.");
				
			}
			
			return Type.resolveClass (name);
			
		}
		
		return null;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private static function application_onExit (_):Void {
		
		for (sharedObject in __sharedObjects) {
			
			sharedObject.flush ();
			
		}
		
	}
	
	
	
	
	// Getters & Setters
	
	
	
	
	private function get_size ():Int {
		
		try {
			
			var d = Serializer.run (data);
			return Bytes.ofString (d).length;
			
		} catch (e:Dynamic) {
			
			return 0;
			
		}
		
	}
	
	
}
