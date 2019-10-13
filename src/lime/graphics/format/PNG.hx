package lime.graphics.format;


import haxe.io.Bytes;
import lime.graphics.utils.ImageCanvasUtil;
import lime.graphics.Image;
import lime.utils.compress.Zlib;
import lime.utils.UInt8Array;

#if (js && html5)
import js.Browser;
#end

#if format
import format.png.Data;
import format.png.Writer;
// import format.tools.Deflate;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime.graphics.ImageBuffer)
class PNG {
	
	public static function encode (image:Image):Bytes {
		
		if (image.premultiplied || image.format != RGBA32) {
			
			// TODO: Handle encode from different formats
			
			image = image.clone ();
			image.premultiplied = false;
			image.format = RGBA32;
			
		}
		
		#if js
		
		image.type = CANVAS;
		ImageCanvasUtil.sync (image, false);
		
		if (image.buffer.__srcCanvas != null) {
			
			var data = image.buffer.__srcCanvas.toDataURL ("image/png");
			#if nodejs
			var buffer = new js.node.Buffer ((data.split (";base64,")[1]:String), "base64").toString ("binary");
			#else
			var buffer = Browser.window.atob (data.split (";base64,")[1]);
			#end
			var bytes = Bytes.alloc (buffer.length);
			
			for (i in 0...buffer.length) {
				
				bytes.set (i, buffer.charCodeAt (i));
				
			}
			
			return bytes;
			
		}
		
		#end
		
		return null;
		
	}
	
	
}