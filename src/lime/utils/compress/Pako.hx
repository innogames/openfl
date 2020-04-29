package lime.utils.compress;

import js.lib.ArrayBuffer;

@:native("pako")
extern class Pako {
	static function deflate(data:ArrayBuffer):ArrayBuffer;
	static function inflate(data:ArrayBuffer):ArrayBuffer;
	static function deflateRaw(data:ArrayBuffer):ArrayBuffer;
	static function inflateRaw(data:ArrayBuffer):ArrayBuffer;
	static function gzip(data:ArrayBuffer):ArrayBuffer;
	static function ungzip(data:ArrayBuffer):ArrayBuffer;
}
