package openfl;

import openfl.display.BitmapData;

@:deprecated("openfl.Assets was removed and is only present here for compiling unused code in Zame Particles library")
@:native("(undefined)")
extern class Assets {
	static function getText(id:String):String;
	static function getBitmapData(id:String):BitmapData;
}
