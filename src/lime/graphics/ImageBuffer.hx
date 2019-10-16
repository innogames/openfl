package lime.graphics;

import lime.utils.UInt8Array;

import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Image in HTMLImage;
import js.html.ImageData;
import js.html.Uint8ClampedArray;
import js.Browser;

@:allow(lime.graphics.Image)
class ImageBuffer {
	
	
	public var bitsPerPixel:Int;
	public var data:UInt8Array;
	public var format:PixelFormat;
	public var height:Int;
	public var premultiplied:Bool;
	public var src (get, set):Dynamic;
	public var stride (get, never):Int;
	public var transparent:Bool;
	public var width:Int;
	
	private var __srcCanvas:CanvasElement;
	private var __srcContext:CanvasRenderingContext2D;
	private var __srcImage:HTMLImage;
	private var __srcImageData:ImageData;
	
	
	public function new (data:UInt8Array = null, width:Int = 0, height:Int = 0, bitsPerPixel:Int = 32, format:PixelFormat = null) {
		
		this.data = data;
		this.width = width;
		this.height = height;
		this.bitsPerPixel = bitsPerPixel;
		this.format = (format == null ? RGBA32 : format);
		premultiplied = false;
		transparent = true;
		
	}
	
	
	public function clone ():ImageBuffer {
		
		var buffer = new ImageBuffer (data, width, height, bitsPerPixel);
		
		if (data != null) {
			
			buffer.data = new UInt8Array (data.byteLength);
			var copy = new UInt8Array (data);
			buffer.data.set (copy);
			
		} else if (__srcImageData != null) {
			
			buffer.__srcCanvas = Browser.document.createCanvasElement();
			buffer.__srcContext = buffer.__srcCanvas.getContext ("2d");
			buffer.__srcCanvas.width = __srcImageData.width;
			buffer.__srcCanvas.height = __srcImageData.height;
			buffer.__srcImageData = buffer.__srcContext.createImageData (__srcImageData.width, __srcImageData.height);
			var copy = new Uint8ClampedArray (__srcImageData.data);
			buffer.__srcImageData.data.set (copy);
			
		} else if (__srcCanvas != null) {
			
			buffer.__srcCanvas = Browser.document.createCanvasElement();
			buffer.__srcContext = buffer.__srcCanvas.getContext ("2d");
			buffer.__srcCanvas.width = __srcCanvas.width;
			buffer.__srcCanvas.height = __srcCanvas.height;
			buffer.__srcContext.drawImage (__srcCanvas, 0, 0);
			
		} else {
			
			buffer.__srcImage = __srcImage;
			
		}
		
		buffer.bitsPerPixel = bitsPerPixel;
		buffer.format = format;
		buffer.premultiplied = premultiplied;
		buffer.transparent = transparent;
		return buffer;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_src ():Dynamic {
		
		if (__srcImage != null) return __srcImage;
		return __srcCanvas;
		
	}
	
	
	private function set_src (value:Dynamic):Dynamic {
		
		if (Std.is (value, HTMLImage)) {
			
			__srcImage = value;
			
		} else if (Std.is (value, CanvasElement)) {
			
			__srcCanvas = value;
			__srcContext = __srcCanvas.getContext ("2d");
			
		}
		
		return value;
		
	}
	
	
	private function get_stride ():Int {
		
		return width * 4;
		
	}
	
	
}