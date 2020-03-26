package lime.utils.compress;


import haxe.io.Bytes;

#if flash
import flash.utils.CompressionAlgorithm;
import flash.utils.ByteArray;
#end

class LZMA {
	
	
	public static function compress (bytes:Bytes):Bytes {
		
		#if flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.compress (CompressionAlgorithm.LZMA);
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
	public static function decompress (bytes:Bytes):Bytes {
		
		#if flash
		
		var byteArray:ByteArray = cast bytes.getData ();
		
		var data = new ByteArray ();
		data.writeBytes (byteArray);
		data.uncompress (CompressionAlgorithm.LZMA);
		
		return Bytes.ofData (data);
		
		#else
		
		return null;
		
		#end
		
	}
	
	
}