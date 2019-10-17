package lime.graphics.format;

import haxe.io.Bytes;
import js.Browser;
import lime.graphics.utils.ImageCanvasUtil;
import lime.graphics.Image;

@:access(lime.graphics.ImageBuffer)
class JPEG {
	public static function encode(image:Image, quality:Int):Bytes {
		if (image.premultiplied || image.format != RGBA32) {
			// TODO: Handle encode from different formats

			image = image.clone();
			image.premultiplied = false;
			image.format = RGBA32;
		}

		image.type = CANVAS;
		ImageCanvasUtil.sync(image, false);

		if (image.buffer.__srcCanvas != null) {
			var data = image.buffer.__srcCanvas.toDataURL("image/jpeg", quality / 100);
			var buffer = Browser.window.atob(data.split(";base64,")[1]);
			var bytes = Bytes.alloc(buffer.length);

			for (i in 0...buffer.length) {
				bytes.set(i, buffer.charCodeAt(i));
			}

			return bytes;
		}

		return null;
	}
}
