package openfl.filters;


import lime.graphics.utils.ImageDataUtil;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(openfl.geom.Point)
@:access(openfl.geom.Rectangle)


@:final class GlowFilter extends BitmapFilter {
	
	
	public var alpha (get, set):Float;
	public var blurX (get, set):Float;
	public var blurY (get, set):Float;
	public var color (get, set):Int;
	public var inner (get, set):Bool;
	public var knockout (get, set):Bool;
	public var quality (get, set):Int;
	public var strength (get, set):Float;
	
	private var __alpha:Float;
	private var __blurX:Float;
	private var __blurY:Float;
	private var __color:Int;
	private var __inner:Bool;
	private var __knockout:Bool;
	private var __quality:Int;
	private var __strength:Float;
	
	
	public function new (color:Int = 0xFF0000, alpha:Float = 1, blurX:Float = 6, blurY:Float = 6, strength:Float = 2, quality:Int = 1, inner:Bool = false, knockout:Bool = false) {
		
		super ();
		
		__color = color;
		__alpha = alpha;
		this.blurX = blurX;
		this.blurY = blurY;
		__strength = strength;
		this.quality = quality;
		__inner = inner;
		__knockout = knockout;
		
		__needSecondBitmapData = true;
		__preserveObject = true;
		__renderDirty = true;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new GlowFilter (__color, __alpha, __blurX, __blurY, __strength, __quality, __inner, __knockout);
		
	}
	
	
	private override function __applyFilter (bitmapData:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point):BitmapData {
		
		// TODO: Support knockout, inner
		@:privateAccess var pixelRatio = sourceBitmapData.__pixelRatio; 
		var r = (__color >> 16) & 0xFF;
		var g = (__color >> 8) & 0xFF;
		var b = __color & 0xFF;
		sourceBitmapData.colorTransform (sourceBitmapData.rect, new ColorTransform (0, 0, 0, __alpha, r, g, b, 0));
		
		var finalImage = ImageDataUtil.gaussianBlur (bitmapData.image, sourceBitmapData.image, sourceRect.__toLimeRectangle (), destPoint.__toLimeVector2 (), __blurX * pixelRatio, __blurY * pixelRatio, __quality, __strength);
		
		if (finalImage == bitmapData.image) return bitmapData;
		return sourceBitmapData;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_alpha ():Float {
		
		return __alpha;
		
	}
	
	
	private function set_alpha (value:Float):Float {
		
		if (value != __alpha) __renderDirty = true;
		return __alpha = value;
		
	}
	
	
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
	
	
	private function get_color ():Int {
		
		return __color;
		
	}
	
	
	private function set_color (value:Int):Int {
		
		if (value != __color) __renderDirty = true;
		return __color = value;
		
	}
	
	
	private function get_inner ():Bool {
		
		return __inner;
		
	}
	
	
	private function set_inner (value:Bool):Bool {
		
		if (value != __inner) __renderDirty = true;
		return __inner = value;
		
	}
	
	
	private function get_knockout ():Bool {
		
		return __knockout;
		
	}
	
	
	private function set_knockout (value:Bool):Bool {
		
		if (value != __knockout) __renderDirty = true;
		return __knockout = value;
		
	}
	
	
	private function get_quality ():Int {
		
		return __quality;
		
	}
	
	
	private function set_quality (value:Int):Int {
		
		if (value != __quality) __renderDirty = true;
		return __quality = value;
		
	}
	
	
	private function get_strength ():Float {
		
		return __strength;
		
	}
	
	
	private function set_strength (value:Float):Float {
		
		if (value != __strength) __renderDirty = true;
		return __strength = value;
		
	}
	
	
}