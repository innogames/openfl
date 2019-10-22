package lime.system;

import lime.utils.ArrayBuffer;
import lime.utils.UInt8Array;
import lime.utils.UInt16Array;
import openfl.utils.Endian;

class System {
	

	public static var endianness (get, never):Endian;
	
	static var __endianness:Endian;
	
	static function get_endianness ():Endian {
		
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
	
	
}
