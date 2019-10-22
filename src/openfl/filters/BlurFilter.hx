package openfl.filters;


import lime.graphics.utils.ImageDataUtil;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(openfl.geom.Point)
@:access(openfl.geom.Rectangle)
@:final class BlurFilter extends BitmapFilter {
	
	
	public var blurX (get, set):Float;
	public var blurY (get, set):Float;
	public var quality (get, set):Int;
	
	private var __blurX:Float;
	private var __blurY:Float;
	private var __quality:Int;
	
	
	public function new (blurX:Float = 4, blurY:Float = 4, quality:Int = 1) {
		
		super ();
		
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
		
		__needSecondBitmapData = true;
		__preserveObject = false;
		__renderDirty = true;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new BlurFilter (__blurX, __blurY, __quality);
		
	}
	
	
	private override function __applyFilter (bitmapData:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point):BitmapData {
		
		@:privateAccess var pixelRatio = sourceBitmapData.__pixelRatio; 
		var finalImage = ImageDataUtil.gaussianBlur (bitmapData.image, sourceBitmapData.image, sourceRect.__toLimeRectangle (), destPoint.__toLimeVector2 (), __blurX * pixelRatio, __blurY * pixelRatio, __quality);
		if (finalImage == bitmapData.image) return bitmapData;
		return sourceBitmapData;
		
	}

	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_blurX ():Float {
		
		return __blurX;
		
	}
	
	
	private function set_blurX (value:Float):Float {
		
		if (value != __blurX) {
			__blurX = value;
			__renderDirty = true;
			__leftExtension = (value > 0 ? Math.ceil (value) : 0);
			__rightExtension = __leftExtension;
		}
		return value;
		
	}
	
	
	private function get_blurY ():Float {
		
		return __blurY;
		
	}
	
	
	private function set_blurY (value:Float):Float {
		
		if (value != __blurY) {
			__blurY = value;
			__renderDirty = true;
			__topExtension = (value > 0 ? Math.ceil (value) : 0);
			__bottomExtension = __topExtension;
		}
		return value;
		
	}
	
	
	private function get_quality ():Int {
		
		return __quality;
		
	}
	
	
	private function set_quality (value:Int):Int {
		
		if (value != __quality) __renderDirty = true;
		return __quality = value;
		
	}
	
	
}
