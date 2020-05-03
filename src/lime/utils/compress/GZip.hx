package lime.utils.compress;

import haxe.io.Bytes;

class GZip {
	public static function compress(bytes:Bytes):Bytes {
		#if js
		var data = Pako.gzip(bytes.getData());
		return Bytes.ofData(data);
		#else
		return null;
		#end
	}

	public static function decompress(bytes:Bytes):Bytes {
		#if js
		var data = Pako.ungzip(bytes.getData());
		return Bytes.ofData(data);
		#else
		return null;
		#end
	}
}
