package lime.utils;


import haxe.io.Bytes in HaxeBytes;
import haxe.io.BytesData;
import lime.app.Future;
import lime.net.HTTPRequest;

@:access(haxe.io.Bytes)
@:forward


abstract Bytes(HaxeBytes) from HaxeBytes to HaxeBytes {
	
	
	public function new (length:Int, bytesData:BytesData) {
		
		#if js
		this = new HaxeBytes (bytesData);
		#else
		this = new HaxeBytes (length, bytesData);
		#end
		
	}
	
	
	public static function alloc (length:Int):Bytes {
		
		var bytes = HaxeBytes.alloc (length);
		return new Bytes (bytes.length, bytes.getData ());
		
	}
	
	
	public static inline function fastGet (b:BytesData, pos:Int):Int {
		
		return HaxeBytes.fastGet (b, pos);
		
	}
	
	
	public static function fromBytes (bytes:haxe.io.Bytes):Bytes {
		
		if (bytes == null) return null;
		
		return new Bytes (bytes.length, bytes.getData ());
		
	}
	
	
	public static function loadFromBytes (bytes:haxe.io.Bytes):Future<Bytes> {
		
		return Future.withValue (fromBytes (bytes));
		
	}
	
	
	public static function loadFromFile (path:String):Future<Bytes> {
		
		var request = new HTTPRequest<Bytes> ();
		return request.load (path);
		
	}
	
	
	public static function ofData (b:BytesData):Bytes {
		
		var bytes = HaxeBytes.ofData (b);
		return new Bytes (bytes.length, bytes.getData ());
		
	}
	
	
	public static function ofString (s:String):Bytes {
		
		var bytes = HaxeBytes.ofString (s);
		return new Bytes (bytes.length, bytes.getData ());
		
	}
	
	
}
