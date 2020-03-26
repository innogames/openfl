package lime.utils.compress;


import haxe.io.Bytes;

#if flash
import flash.utils.ByteArray;
#end

class Deflate {
	
	
	public static function compress (bytes:Bytes):Bytes {
		
		#if js
		
		var data = Pako.deflateRaw (bytes.getData ());
		return Bytes.ofData (data);
		
		#elseif flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.deflate ();
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
	public static function decompress (bytes:Bytes):Bytes {
		
		#if js
		
		var data = Pako.inflateRaw (bytes.getData ());
		return Bytes.ofData (data);
		
		#elseif flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.inflate ();
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
}