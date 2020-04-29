package lime.graphics;


import haxe.crypto.BaseCode;
import haxe.io.Bytes;
import lime.app.Future;
import lime.graphics.format.BMP;
import lime.graphics.format.JPEG;
import lime.graphics.format.PNG;
import lime.graphics.utils.ImageCanvasUtil;
import lime.graphics.utils.ImageDataUtil;
import lime.math.ColorMatrix;
import lime.math.Rectangle;
import lime.math.Vector2;
import openfl.geom.Point;
import openfl.utils.Endian;
import lime.utils.UInt8Array;

import lime._backend.html5.HTML5HTTPRequest;
import js.html.CanvasElement;
import js.html.ImageElement;
import js.html.Image in JSImage;

@:allow(lime.graphics.util.ImageCanvasUtil)
@:allow(lime.graphics.util.ImageDataUtil)
@:access(lime.math.ColorMatrix)
@:access(lime.math.Rectangle)
@:access(lime.math.Vector2)
@:access(lime._backend.html5.HTML5HTTPRequest)
class Image {
	
	private static var __base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	private static var __base64Encoder:BaseCode;
	
	public var buffer:ImageBuffer;
	public var data (get, set):UInt8Array;
	public var dirty:Bool;
	public var format (get, set):PixelFormat;
	public var height:Int;
	public var powerOfTwo (get, set):Bool;
	public var premultiplied (get, set):Bool;
	public var rect (get, null):Rectangle;
	public var src (get, set):Dynamic;
	public var transparent (get, set):Bool;
	public var type:ImageType;
	public var version:Int;
	public var width:Int;
	public var x:Float;
	public var y:Float;
	
	
	public function new (buffer:ImageBuffer = null, width:Int = -1, height:Int = -1, color:Null<Int> = null, type:ImageType = null) {
		
		this.width = width;
		this.height = height;
		
		version = 0;
		
		if (type == null) {
			
			type = CANVAS;
			
		}
		
		this.type = type;
		
		if (buffer == null) {
			
			if (width > 0 && height > 0) {
				
				switch (this.type) {
					
					case CANVAS:
						
						this.buffer = new ImageBuffer (null, width, height);
						ImageCanvasUtil.createCanvas (this, width, height);
						
						if (color != null && color != 0) {
							
							fillRect (new Rectangle (0, 0, width, height), color);
							
						}
					
					case DATA:
						
						this.buffer = new ImageBuffer (new UInt8Array (width * height * 4), width, height);
						
						if (color != null && color != 0) {
							
							fillRect (new Rectangle (0, 0, width, height), color);
							
						}
					
				}
				
			}
			
		} else {
			
			__fromImageBuffer (buffer);
			
		}
		
	}
	
	
	public function clone ():Image {
		
		if (buffer != null) {
			
			if (type == CANVAS) {
				
				ImageCanvasUtil.convertToCanvas (this);
				
			} else {
				
				ImageCanvasUtil.convertToData (this);
				
			}
			
			var image = new Image (buffer.clone (), width, height, null, type);
			image.version = version;
			return image;
			
		} else {
			
			return new Image (null, width, height, null, type);
			
		}
		
	}
	
	
	public function colorTransform (rect:Rectangle, colorMatrix:ColorMatrix):Void {
		
		rect = __clipRect (rect);
		if (buffer == null || rect == null) return;
		
		ImageCanvasUtil.convertToData (this);
		ImageDataUtil.colorTransform (this, rect, colorMatrix);
		
	}
	
	
	public function copyChannel (sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, sourceChannel:ImageChannel, destChannel:ImageChannel):Void {
		
		sourceRect = __clipRect (sourceRect);
		if (buffer == null || sourceRect == null) return;
		if (destChannel == ALPHA && !transparent) return;
		if (sourceRect.width <= 0 || sourceRect.height <= 0) return;
		if (sourceRect.x + sourceRect.width > sourceImage.width) sourceRect.width = sourceImage.width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceImage.height) sourceRect.height = sourceImage.height - sourceRect.y;
		
		ImageCanvasUtil.convertToData (this);
		ImageCanvasUtil.convertToData (sourceImage);
		
		ImageDataUtil.copyChannel (this, sourceImage, sourceRect, destPoint, sourceChannel, destChannel);
		
	}
	
	
	public function copyPixels (sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, alphaImage:Image = null, alphaPoint:Point = null, mergeAlpha:Bool = false):Void {
		
		if (buffer == null || sourceImage == null) return;
		if (sourceRect.width <= 0 || sourceRect.height <= 0) return;
		if (width <= 0 || height <= 0) return;
		
		if (sourceRect.x + sourceRect.width > sourceImage.width) sourceRect.width = sourceImage.width - sourceRect.x;
		if (sourceRect.y + sourceRect.height > sourceImage.height) sourceRect.height = sourceImage.height - sourceRect.y;
		
		if (sourceRect.x < 0) {
			
			sourceRect.width += sourceRect.x;
			sourceRect.x = 0;
			
		}
		
		if (sourceRect.y < 0) {
			
			sourceRect.height += sourceRect.y;
			sourceRect.y = 0;
			
		}
		
		if (destPoint.x + sourceRect.width > width) sourceRect.width = width - destPoint.x;
		if (destPoint.y + sourceRect.height > height) sourceRect.height = height - destPoint.y;
		
		if (destPoint.x < 0) {
			
			sourceRect.width += destPoint.x;
			sourceRect.x -= destPoint.x;
			destPoint.x = 0;
			
		}
		
		if (destPoint.y < 0) {
			
			sourceRect.height += destPoint.y;
			sourceRect.y -= destPoint.y;
			destPoint.y = 0;
			
		}
		
		if (sourceImage == this && destPoint.x < sourceRect.right && destPoint.y < sourceRect.bottom) {
			
			// TODO: Optimize further?
			sourceImage = clone ();
			
		}
		
		switch (type) {
			
			case CANVAS:
				
				if (alphaImage != null || sourceImage.type != CANVAS) {
					
					ImageCanvasUtil.convertToData (this);
					ImageCanvasUtil.convertToData (sourceImage);
					if (alphaImage != null) ImageCanvasUtil.convertToData (alphaImage);
					
					ImageDataUtil.copyPixels (this, sourceImage, sourceRect, destPoint, alphaImage, alphaPoint, mergeAlpha);
					
				} else {

					ImageCanvasUtil.convertToCanvas (this);
					ImageCanvasUtil.convertToCanvas (sourceImage);
					ImageCanvasUtil.copyPixels (this, sourceImage, sourceRect, destPoint, alphaImage, alphaPoint, mergeAlpha);
					
				}
			
			case DATA:
				
				ImageCanvasUtil.convertToData (this);
				ImageCanvasUtil.convertToData (sourceImage);
				if (alphaImage != null) ImageCanvasUtil.convertToData (alphaImage);
				
				ImageDataUtil.copyPixels (this, sourceImage, sourceRect, destPoint, alphaImage, alphaPoint, mergeAlpha);
				
		}
		
	}
	
	
	public function encode (format:String = "png", quality:Int = 90):Bytes {
		
		switch (format) {
			
			case "png":
				
				return PNG.encode (this);
			
			case "jpg", "jpeg":
				
				return JPEG.encode (this, quality);
			
			case "bmp":
				
				return BMP.encode (this);
			
			default:
			
		}
		
		return null;
		
	}
	
	
	public function fillRect (rect:Rectangle, color:Int, format:PixelFormat = null):Void {
		
		rect = __clipRect (rect);
		if (buffer == null || rect == null) return;
		
		switch (type) {
			
			case CANVAS:
				
				ImageCanvasUtil.fillRect (this, rect, color, format);
			
			case DATA:
				
				ImageCanvasUtil.convertToData (this);
				
				if (buffer.data.length == 0) return;
				
				ImageDataUtil.fillRect (this, rect, color, format);
			
		}
		
	}
	
	
	public function floodFill (x:Int, y:Int, color:Int, format:PixelFormat = null):Void {
		
		if (buffer == null) return;
		
		ImageCanvasUtil.convertToData (this);
		
		ImageDataUtil.floodFill (this, x, y, color, format);
		
	}
	
	
	public static function fromBase64 (base64:String, type:String):Image {
		
		if (base64 == null) return null;
		var image = new Image ();
		image.__fromBase64 (base64, type);
		return image;
		
	}
	
	
	public static function fromBytes (bytes:Bytes):Image {
		
		if (bytes == null) return null;
		var image = new Image ();
		image.__fromBytes (bytes);
		return image;
		
	}
	
	
	public static function fromCanvas (canvas:CanvasElement):Image {
		
		if (canvas == null) return null;
		var buffer = new ImageBuffer (null, canvas.width, canvas.height);
		buffer.src = canvas;
		var image = new Image (buffer);
		image.type = CANVAS;
		return image;
		
	}
	
	
	public static function fromFile (path:String):Image {
		
		if (path == null) return null;
		var image = new Image ();
		image.__fromFile (path);
		return image;
		
	}
	
	
	public static function fromImageElement (image:ImageElement):Image {
		
		if (image == null) return null;
		var buffer = new ImageBuffer (null, image.width, image.height);
		buffer.src = image;
		var _image = new Image (buffer);
		_image.type = CANVAS;
		return _image;
		
	}
	
	
	public function getColorBoundsRect (mask:Int, color:Int, findColor:Bool = true, format:PixelFormat = null):Rectangle {
		
		if (buffer == null) return null;
		
		if (type == CANVAS) {
			ImageCanvasUtil.convertToData (this);
		}

		return ImageDataUtil.getColorBoundsRect (this, mask, color, findColor, format);
		
	}
	
	
	public function getPixel (x:Int, y:Int, format:PixelFormat = null):Int {
		
		if (buffer == null || x < 0 || y < 0 || x >= width || y >= height) return 0;
		
		ImageCanvasUtil.convertToData (this);
		
		return ImageDataUtil.getPixel (this, x, y, format);
		
	}
	
	
	public function getPixel32 (x:Int, y:Int, format:PixelFormat = null):Int {
		
		if (buffer == null || x < 0 || y < 0 || x >= width || y >= height) return 0;
		
		ImageCanvasUtil.convertToData (this);
		
		return ImageDataUtil.getPixel32 (this, x, y, format);
		
	}
	
	
	public function getPixels (rect:Rectangle, format:PixelFormat = null):Bytes {
		
		if (buffer == null) return null;
		
		ImageCanvasUtil.convertToData (this);
		
		return ImageDataUtil.getPixels (this, rect, format);
		
	}
	
	
	public static function loadFromBase64 (base64:String, type:String):Future<Image> {
		
		if (base64 == null || type == null) return Future.withValue (null);
		
		return HTML5HTTPRequest.loadImage ("data:" + type + ";base64," + base64);
		
	}
	
	
	public static function loadFromBytes (bytes:Bytes):Future<Image> {
		
		if (bytes == null) return Future.withValue (null);
		
		var type;
		
		if (__isPNG (bytes)) {
			
			type = "image/png";
			
		} else if (__isJPG (bytes)) {
			
			type = "image/jpeg";
			
		} else if (__isGIF (bytes)) {
			
			type = "image/gif";
			
		} else if (__isWebP (bytes)) {
			
			type = "image/webp";
			
		} else {
			
			//throw "Image tried to read PNG/JPG Bytes, but found an invalid header.";
			return Future.withValue (null);
			
		}
		
		return loadFromBase64 (__base64Encode (bytes), type);
		
	}
	
	
	public static function loadFromFile (path:String):Future<Image> {
		
		if (path == null) return Future.withValue (null);
		
		return HTML5HTTPRequest.loadImage (path);
		
	}
	
	
	public function merge (sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, redMultiplier:Int, greenMultiplier:Int, blueMultiplier:Int, alphaMultiplier:Int):Void {
		
		if (buffer == null || sourceImage == null) return;
		
		if (type == CANVAS) {
			ImageCanvasUtil.convertToCanvas (this);
		}

		ImageCanvasUtil.convertToData (this);
		ImageCanvasUtil.convertToData (sourceImage);
		
		ImageDataUtil.merge (this, sourceImage, sourceRect, destPoint, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		
	}
	
	
	public function scroll (x:Int, y:Int):Void {
		
		if (buffer == null) return;
		
		switch (type) {
			
			case CANVAS:
				
				ImageCanvasUtil.scroll (this, x, y);
			
			case DATA:
				
				copyPixels (this, rect, new Point (x, y));
			
		}
		
	}
	
	
	public function setPixel (x:Int, y:Int, color:Int, format:PixelFormat = null):Void {
		
		if (buffer == null || x < 0 || y < 0 || x >= width || y >= height) return;
		
		ImageCanvasUtil.convertToData (this);
		
		ImageDataUtil.setPixel (this, x, y, color, format);
		
	}
	
	
	public function setPixel32 (x:Int, y:Int, color:Int, format:PixelFormat = null):Void {
		
		if (buffer == null || x < 0 || y < 0 || x >= width || y >= height) return;
		
		ImageCanvasUtil.convertToData (this);
		
		ImageDataUtil.setPixel32 (this, x, y, color, format);
		
	}
	
	
	public function setPixels (rect:Rectangle, bytes:Bytes, dataPosition:Int, format:PixelFormat = null, endian:Endian = null):Void {
		
		rect = __clipRect (rect);
		if (buffer == null || rect == null) return;
		//if (endian == null) endian = System.endianness; // TODO: System endian order
		if (endian == null) endian = BIG_ENDIAN;
		
		ImageCanvasUtil.convertToData (this);
		
		ImageDataUtil.setPixels (this, rect, bytes, dataPosition, format, endian);
		
	}
	
	
	public function threshold (sourceImage:Image, sourceRect:Rectangle, destPoint:Vector2, operation:String, threshold:Int, color:Int = 0x00000000, mask:Int = 0xFFFFFFFF, copySource:Bool = false, format:PixelFormat = null):Int {
		
		if (buffer == null || sourceImage == null || sourceRect == null) return 0;
		
		ImageCanvasUtil.convertToData (this);
		ImageCanvasUtil.convertToData (sourceImage);
		
		return ImageDataUtil.threshold (this, sourceImage, sourceRect, destPoint, operation, threshold, color, mask, copySource, format);
		
	}
	
	
	private static function __base64Encode (bytes:Bytes):String {
		
		var extension = switch (bytes.length % 3) {
			
			case 1: "==";
			case 2: "=";
			default: "";
			
		}
		
		if (__base64Encoder == null) {
			
			__base64Encoder = new BaseCode (Bytes.ofString (__base64Chars));
			
		}
		
		return __base64Encoder.encodeBytes (bytes).toString () + extension;
		
	}
	
	
	private function __clipRect (r:Rectangle):Rectangle {
		
		if (r == null) return null;
		
		if (r.x < 0) {
			
			r.width -= -r.x;
			r.x = 0;
			
			if (r.x + r.width <= 0) return null;
			
		}
		
		if (r.y < 0) {
			
			r.height -= -r.y;
			r.y = 0;
			
			if (r.y + r.height <= 0) return null;
			
		}
		
		if (r.x + r.width >= width) {
			
			r.width -= r.x + r.width - width;
			
			if (r.width <= 0) return null;
			
		}
		
		if (r.y + r.height >= height) {
			
			r.height -= r.y + r.height - height;
			
			if (r.height <= 0) return null;
			
		}
		
		return r;
		
	}
	
	
	private function __fromBase64 (base64:String, type:String, onload:Image->Void = null):Void {
		
		var image = new JSImage ();
		
		var image_onLoaded = function (event) {
			
			buffer = new ImageBuffer (null, image.width, image.height);
			buffer.__srcImage = cast image;
			
			width = buffer.width;
			height = buffer.height;
			
			if (onload != null) {
				
				onload (this);
				
			}
			
		}
		
		image.addEventListener ("load", image_onLoaded, false);
		image.src = "data:" + type + ";base64," + base64;
		
	}
	
	
	private function __fromBytes (bytes:Bytes, onload:Image->Void = null):Void {
		
		var type;
		
		if (__isPNG (bytes)) {
			
			type = "image/png";
			
		} else if (__isJPG (bytes)) {
			
			type = "image/jpeg";
			
		} else if (__isGIF (bytes)) {
			
			type = "image/gif";
			
		} else {
			
			//throw "Image tried to read PNG/JPG Bytes, but found an invalid header.";
			return;
			
		}
		
		__fromBase64 (__base64Encode (bytes), type, onload);
		
	}
	
	
	private function __fromFile (path:String, onload:Image->Void = null, onerror:Void->Void = null):Void {
		
		var image = new JSImage ();
		
		if (!HTML5HTTPRequest.__isSameOrigin (path)) {
			
			image.crossOrigin = "Anonymous";
			
		}
		
		image.onload = function (_) {
			
			buffer = new ImageBuffer (null, image.width, image.height);
			buffer.__srcImage = cast image;
			
			width = image.width;
			height = image.height;
			
			if (onload != null) {
				
				onload (this);
				
			}
			
		}
		
		image.onerror = function (_) {
			
			if (onerror != null) {
				
				onerror ();
				
			}
			
		}
		
		image.src = path;
		
		// Another IE9 bug: loading 20+ images fails unless this line is added.
		// (issue #1019768)
		if (image.complete) { }
		
	}
	
	
	private function __fromImageBuffer (buffer:ImageBuffer):Void {
		
		this.buffer = buffer;
		
		if (buffer != null) {
			
			if (width == -1) {
				
				this.width = buffer.width;
				
			}
			
			if (height == -1) {
				
				this.height = buffer.height;
				
			}
			
		}
		
	}
	
	
	private static function __isGIF (bytes:Bytes):Bool {
		
		if (bytes == null || bytes.length < 6) return false;
		
		var header = bytes.getString (0, 6);
		return (header == "GIF87a" || header == "GIF89a");
		
	}
	
	
	private static function __isJPG (bytes:Bytes):Bool {
		
		if (bytes == null || bytes.length < 4) return false;
		
		return bytes.get (0) == 0xFF && bytes.get (1) == 0xD8 && bytes.get (bytes.length - 2) == 0xFF && bytes.get (bytes.length -1) == 0xD9;
		
	}
	
	
	private static function __isPNG (bytes:Bytes):Bool {
		
		if (bytes == null || bytes.length < 8) return false;
		
		return (bytes.get (0) == 0x89 && bytes.get (1) == "P".code && bytes.get (2) == "N".code && bytes.get (3) == "G".code && bytes.get (4) == "\r".code && bytes.get (5) == "\n".code && bytes.get (6) == 0x1A && bytes.get (7) == "\n".code);
		
	}
	
	
	private static function __isWebP (bytes:Bytes):Bool {
		
		if (bytes == null || bytes.length < 16) return false;
		
		return (bytes.getString (0, 4) == "RIFF" && bytes.getString (8, 4) == "WEBP");
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_data ():UInt8Array {
		
		if (buffer.data == null && buffer.width > 0 && buffer.height > 0) {
			
			ImageCanvasUtil.convertToData (this);
			
		}
		
		return buffer.data;
		
	}
	
	
	private function set_data (value:UInt8Array):UInt8Array {
		
		return buffer.data = value;
		
	}
	
	
	private function get_format ():PixelFormat {
		
		return buffer.format;
		
	}
	
	
	private function set_format (value:PixelFormat):PixelFormat {
		
		if (buffer.format != value) {
			
			switch (type) {
				
				case DATA:
					
					ImageDataUtil.setFormat (this, value);
				
				default:
				
			}
			
		}
		
		return buffer.format = value;
		
	}
	
	
	private function get_powerOfTwo ():Bool {
		
		return ((buffer.width != 0) && ((buffer.width & (~buffer.width + 1)) == buffer.width)) && ((buffer.height != 0) && ((buffer.height & (~buffer.height + 1)) == buffer.height));
		
	}
	
	
	private function set_powerOfTwo (value:Bool):Bool {
		
		if (value != powerOfTwo) {
			
			var newWidth = 1;
			var newHeight = 1;
			
			while (newWidth < buffer.width) {
				
				newWidth <<= 1;
				
			}
			
			while (newHeight < buffer.height) {
				
				newHeight <<= 1;
				
			}
			
			switch (type) {
				
				case CANVAS:
					
					// TODO
				
				case DATA:
					
					ImageDataUtil.resizeBuffer (this, newWidth, newHeight);
				
			}
			
		}
		
		return value;
		
	}
	
	
	private function get_premultiplied ():Bool {
		
		return buffer.premultiplied;
		
	}
	
	
	private function set_premultiplied (value:Bool):Bool {
		
		if (value && !buffer.premultiplied) {
			
			ImageCanvasUtil.convertToData (this);
			ImageDataUtil.multiplyAlpha (this);
			
		} else if (!value && buffer.premultiplied) {
			
			switch (type) {
				
				case DATA:
					
					ImageCanvasUtil.convertToData (this);
					ImageDataUtil.unmultiplyAlpha (this);
				
				case CANVAS:
					
					// TODO
				
			}
			
		}
		
		return value;
		
	}
	
	
	private function get_rect ():Rectangle {
		
		return new Rectangle (0, 0, width, height);
		
	}
	
	
	private function get_src ():Dynamic {
		
		return buffer.src;
		
	}
	
	
	private function set_src (value:Dynamic):Dynamic {
		
		return buffer.src = value;
		
	}
	
	
	private function get_transparent ():Bool {
		
		if (buffer == null) return false;
		return buffer.transparent;
		
	}
	
	
	private function set_transparent (value:Bool):Bool {
		
		// TODO, modify data to set transparency
		if (buffer == null) return false;
		return buffer.transparent = value;
		
	}
	
	
}
