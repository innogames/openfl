package openfl.filters;

import lime.graphics.utils.ImageCanvasUtil;
import lime.math.color.RGBA;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

final class ColorMatrixFilter extends BitmapFilter {
	// private static var __colorMatrixShader = new ColorMatrixShader ();
	public var matrix(get, set):Array<Float>;

	private var __matrix:Array<Float>;

	public function new(matrix:Array<Float> = null) {
		super();

		this.matrix = matrix;

		__needSecondBitmapData = false;
	}

	public override function clone():BitmapFilter {
		return new ColorMatrixFilter(__matrix);
	}

	private override function __applyFilter(destBitmapData:BitmapData, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point):BitmapData {
		var sourceImage = sourceBitmapData.image;
		var image = destBitmapData.image;

		ImageCanvasUtil.convertToData(sourceImage);
		ImageCanvasUtil.convertToData(image);

		var sourceData = sourceImage.data;
		var destData = image.data;

		var offsetX = Std.int(destPoint.x - sourceRect.x);
		var offsetY = Std.int(destPoint.y - sourceRect.y);
		var sourceStride = sourceBitmapData.width * 4;
		var destStride = destBitmapData.width * 4;

		var sourceFormat = sourceImage.buffer.format;
		var destFormat = image.buffer.format;
		var sourcePremultiplied = sourceImage.buffer.premultiplied;
		var destPremultiplied = image.buffer.premultiplied;

		var sourcePixel:RGBA = 0, destPixel:RGBA = 0;
		var sourceOffset:Int, destOffset:Int;

		for (row in Std.int(sourceRect.y)...Std.int(sourceRect.height)) {
			for (column in Std.int(sourceRect.x)...Std.int(sourceRect.width)) {
				sourceOffset = (row * sourceStride) + (column * 4);
				destOffset = ((row + offsetX) * destStride) + ((column + offsetY) * 4);

				sourcePixel.readUInt8(sourceData, sourceOffset, sourceFormat, sourcePremultiplied);

				if (sourcePixel.a == 0) {
					destPixel = 0;
				} else {
					destPixel.r = Std.int(Math.max(0,
						Math.min((__matrix[0] * sourcePixel.r) + (__matrix[1] * sourcePixel.g) + (__matrix[2] * sourcePixel.b)
							+ (__matrix[3] * sourcePixel.a) + __matrix[4],
							255)));
					destPixel.g = Std.int(Math.max(0,
						Math.min((__matrix[5] * sourcePixel.r) + (__matrix[6] * sourcePixel.g) + (__matrix[7] * sourcePixel.b)
							+ (__matrix[8] * sourcePixel.a) + __matrix[9],
							255)));
					destPixel.b = Std.int(Math.max(0,
						Math.min((__matrix[10] * sourcePixel.r) + (__matrix[11] * sourcePixel.g) + (__matrix[12] * sourcePixel.b)
							+ (__matrix[13] * sourcePixel.a) + __matrix[14],
							255)));
					destPixel.a = Std.int(Math.max(0,
						Math.min((__matrix[15] * sourcePixel.r) + (__matrix[16] * sourcePixel.g) + (__matrix[17] * sourcePixel.b)
							+ (__matrix[18] * sourcePixel.a) + __matrix[19],
							255)));
				}

				destPixel.writeUInt8(destData, destOffset, destFormat, destPremultiplied);
			}
		}

		destBitmapData.image.dirty = true;
		return destBitmapData;
	}

	// Get & Set Methods

	private function get_matrix():Array<Float> {
		return __matrix;
	}

	private function set_matrix(value:Array<Float>):Array<Float> {
		if (value == null) {
			value = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
		}

		return __matrix = value;
	}
}