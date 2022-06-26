package openfl.filters;

import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

abstract class BitmapFilter {
	var __bottomExtension:Int;
	var __leftExtension:Int;
	var __needSecondBitmapData:Bool;
	var __preserveObject:Bool;
	var __renderDirty:Bool;
	var __rightExtension:Int;
	var __topExtension:Int;

	public function new() {
		__bottomExtension = 0;
		__leftExtension = 0;
		__needSecondBitmapData = true;
		__preserveObject = false;
		__rightExtension = 0;
		__topExtension = 0;
	}

	abstract public function clone():BitmapFilter;
	abstract function __applyFilter(bitmapData:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point):Void;
}
