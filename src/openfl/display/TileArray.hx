package openfl.display;

import lime.graphics.opengl.GLBuffer;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Vector;

@:access(openfl.display.Tileset)
@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)
@:beta class TileArray implements ITile {
	private static inline var ID_INDEX = 0;
	private static inline var RECT_INDEX = 1;
	private static inline var MATRIX_INDEX = 5;
	private static inline var ALPHA_INDEX = 11;
	private static inline var COLOR_TRANSFORM_INDEX = 12;
	private static inline var DATA_LENGTH = 21;

	private static inline var SOURCE_DIRTY_INDEX = 0;
	private static inline var MATRIX_DIRTY_INDEX = 1;
	private static inline var ALPHA_DIRTY_INDEX = 2;
	private static inline var COLOR_TRANSFORM_DIRTY_INDEX = 3;
	private static inline var ALL_DIRTY_INDEX = 4;
	private static inline var DIRTY_LENGTH = 5;

	public var alpha(get, set):Float;
	public var colorTransform(get, set):ColorTransform;
	public var id(get, set):Int;
	public var length(get, set):Int;
	public var matrix(get, set):Matrix;
	public var position:Int;
	public var rect(get, set):Rectangle;
	public var shader(get, set):Shader;
	public var tileset(get, set):Tileset;
	public var visible(get, set):Bool;

	private var __buffer:GLBuffer;
	private var __bufferContext:GLRenderContext;
	private var __bufferDirty:Bool;
	private var __bufferData:Float32Array;
	private var __bufferSkipped:Vector<Bool>;
	private var __cacheAlpha:Float;
	private var __cacheDefaultTileset:Tileset;
	private var __cacheDefaultColorTransform:ColorTransform;
	private var __colorTransform:ColorTransform;
	private var __data:Vector<Float>;
	private var __dirty:Vector<Bool>;
	private var __length:Int;
	private var __matrix:Matrix;
	private var __rect:Rectangle;
	private var __shaders:Vector<Shader>;
	private var __tilesets:Vector<Tileset>;
	private var __visible:Vector<Bool>;

	public function new(length:Int = 0) {
		__cacheAlpha = -1;
		__data = new Vector<Float>(length * DATA_LENGTH);
		__dirty = new Vector<Bool>(length * DIRTY_LENGTH);
		__shaders = new Vector<Shader>(length);
		__tilesets = new Vector<Tileset>(length);
		__visible = new Vector<Bool>(length);
		__length = length;
		__cacheDefaultColorTransform = new ColorTransform();
	}

	public function iterator():TileArrayIterator {
		return @:privateAccess new TileArrayIterator(this);
	}

	private inline function __init(position:Int):Void {
		this.position = position;

		alpha = 1;
		colorTransform = null;
		id = 0;
		matrix = null;
		tileset = null;
		visible = true;

		__dirty[ALL_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
	}

	#if !flash
	private function __updateGLBuffer(gl:GLRenderContext, defaultTileset:Tileset, worldAlpha:Float, defaultColorTransform:ColorTransform):GLBuffer {
		// TODO: More closely align internal data format with GL buffer format?

		var attributeLength = 25;
		var stride = attributeLength * 6;
		var bufferLength = __length * stride;

		if (__bufferData == null) {
			__bufferData = new Float32Array(bufferLength);
			__bufferSkipped = new Vector<Bool>(__length);
			__bufferDirty = true;
		} else if (__bufferData.length != bufferLength) {
			// TODO: Use newer Lime GL buffer API to pass length, do not need to recreate if size shrinks

			var data = new Float32Array(bufferLength);

			if (__bufferData.length <= data.length) {
				data.set(__bufferData);

				if (__bufferData.length == 0) {
					__bufferDirty = true;
				} else {
					var cacheLength = __bufferData.length;
					for (i in cacheLength...bufferLength) {
						__dirty[ALL_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
					}
				}
			} else {
				data.set(__bufferData.subarray(0, data.length));
			}

			__bufferData = data;
			__bufferSkipped.length = __length;
			__bufferDirty = true;
		}

		if (__buffer == null || __bufferContext != gl) {
			__bufferContext = gl;
			__buffer = gl.createBuffer();
		}

		gl.bindBuffer(GL.ARRAY_BUFFER, __buffer);

		// TODO: Handle __dirty flags, copy only changed values

		if (__bufferDirty
			|| (__cacheAlpha != worldAlpha)
			|| (__cacheDefaultTileset != defaultTileset)
			|| !__cacheDefaultColorTransform.__equals(defaultColorTransform)) {
			var tileMatrix, tileColorTransform, tileRect = null;

			// TODO: Dirty algorithm per tile?

			var offset = 0;
			var offsetX, offsetY, rotated;
			var alpha, visible, tileset, tileData, id;
			var bitmapWidth, bitmapHeight, tileWidth:Float, tileHeight:Float;
			var uvX, uvY, uvWidth, uvHeight;
			var x, y, x2, y2, x3, y3, x4, y4;
			var redMultiplier,
				greenMultiplier,
				blueMultiplier,
				alphaMultiplier;
			var redOffset, greenOffset, blueOffset, alphaOffset;

			position = 0;

			var __skipTile = function(i, offset:Int):Void {
				for (i in 0...6) {
					__bufferData[offset + (attributeLength * i) + 4] = 0;
				}

				__bufferSkipped[i] = true;
			}

			var textureRegion = openfl.display.BitmapData.TextureRegionResult.helperInstance;

			for (i in 0...__length) {
				position = i;
				offset = i * stride;

				alpha = this.alpha;
				visible = this.visible;

				if (!visible || alpha <= 0) {
					__skipTile(i, offset);
					continue;
				}

				tileset = this.tileset;
				if (tileset == null)
					tileset = defaultTileset;
				if (tileset == null) {
					__skipTile(i, offset);
					continue;
				}

				id = this.id;

				if (id > -1) {
					if (id >= tileset.__data.length) {
						__skipTile(i, offset);
						continue;
					}

					tileData = tileset.__data[id];

					if (tileData == null) {
						__skipTile(i, offset);
						continue;
					}

					tileWidth = tileData.width;
					tileHeight = tileData.height;
					uvX = tileData.__uvX;
					uvY = tileData.__uvY;
					uvWidth = tileData.__uvWidth;
					uvHeight = tileData.__uvHeight;
					offsetX = tileData.offsetX;
					offsetY = tileData.offsetY;
					rotated = tileData.rotated;
				} else {
					tileRect = this.rect;

					if (tileRect == null) {
						__skipTile(i, offset);
						continue;
					}

					tileWidth = tileRect.width;
					tileHeight = tileRect.height;

					if (tileWidth <= 0 || tileHeight <= 0) {
						__skipTile(i, offset);
						continue;
					}

					bitmapWidth = tileset.__bitmapData.width;
					bitmapHeight = tileset.__bitmapData.height;
					uvX = tileRect.x / bitmapWidth;
					uvY = tileRect.y / bitmapHeight;
					uvWidth = tileRect.right / bitmapWidth;
					uvHeight = tileRect.bottom / bitmapHeight;

					offsetX = offsetY = 0;
					rotated = false;
				}

				tileMatrix = this.matrix;
				tileset.__bitmapData.__getTextureRegion(uvX, uvY, uvWidth, uvHeight, textureRegion);

				if (rotated) {
					x = tileMatrix.__transformX(offsetX, offsetY);
					y = tileMatrix.__transformY(offsetX, offsetY);
					x2 = tileMatrix.__transformX(offsetX + tileHeight, offsetY);
					y2 = tileMatrix.__transformY(offsetX + tileHeight, offsetY);
					x3 = tileMatrix.__transformX(offsetX, offsetY + tileWidth);
					y3 = tileMatrix.__transformY(offsetX, offsetY + tileWidth);
					x4 = tileMatrix.__transformX(offsetX + tileHeight, offsetY + tileWidth);
					y4 = tileMatrix.__transformY(offsetX + tileHeight, offsetY + tileWidth);

					__bufferData[offset + 2] = textureRegion.u1;
					__bufferData[offset + 3] = textureRegion.v1;

					__bufferData[offset + attributeLength + 2] = textureRegion.u2;
					__bufferData[offset + attributeLength + 3] = textureRegion.v2;

					__bufferData[offset + (attributeLength * 2) + 2] = textureRegion.u0;
					__bufferData[offset + (attributeLength * 2) + 3] = textureRegion.v0;

					__bufferData[offset + (attributeLength * 3) + 2] = textureRegion.u0;
					__bufferData[offset + (attributeLength * 3) + 3] = textureRegion.v0;

					__bufferData[offset + (attributeLength * 4) + 2] = textureRegion.u2;
					__bufferData[offset + (attributeLength * 4) + 3] = textureRegion.v2;

					__bufferData[offset + (attributeLength * 5) + 2] = textureRegion.u3;
					__bufferData[offset + (attributeLength * 5) + 3] = textureRegion.v3;
				} else {
					x = tileMatrix.__transformX(offsetX, offsetY);
					y = tileMatrix.__transformY(offsetX, offsetY);
					x2 = tileMatrix.__transformX(offsetX + tileWidth, offsetY);
					y2 = tileMatrix.__transformY(offsetX + tileWidth, offsetY);
					x3 = tileMatrix.__transformX(offsetX, offsetY + tileHeight);
					y3 = tileMatrix.__transformY(offsetX, offsetY + tileHeight);
					x4 = tileMatrix.__transformX(offsetX + tileWidth, offsetY + tileHeight);
					y4 = tileMatrix.__transformY(offsetX + tileWidth, offsetY + tileHeight);

					__bufferData[offset + 2] = textureRegion.u0;
					__bufferData[offset + 3] = textureRegion.v0;

					__bufferData[offset + attributeLength + 2] = textureRegion.u1;
					__bufferData[offset + attributeLength + 3] = textureRegion.v1;

					__bufferData[offset + (attributeLength * 2) + 2] = textureRegion.u3;
					__bufferData[offset + (attributeLength * 2) + 3] = textureRegion.v3;

					__bufferData[offset + (attributeLength * 3) + 2] = textureRegion.u3;
					__bufferData[offset + (attributeLength * 3) + 3] = textureRegion.v3;

					__bufferData[offset + (attributeLength * 4) + 2] = textureRegion.u1;
					__bufferData[offset + (attributeLength * 4) + 3] = textureRegion.v1;

					__bufferData[offset + (attributeLength * 5) + 2] = textureRegion.u2;
					__bufferData[offset + (attributeLength * 5) + 3] = textureRegion.v2;
				}

				alpha *= worldAlpha;

				tileColorTransform = this.colorTransform;
				tileColorTransform.__combine(defaultColorTransform);

				redMultiplier = tileColorTransform.redMultiplier;
				greenMultiplier = tileColorTransform.greenMultiplier;
				blueMultiplier = tileColorTransform.blueMultiplier;
				alphaMultiplier = tileColorTransform.alphaMultiplier;
				redOffset = tileColorTransform.redOffset;
				greenOffset = tileColorTransform.greenOffset;
				blueOffset = tileColorTransform.blueOffset;
				alphaOffset = tileColorTransform.alphaOffset;

				__bufferData[offset + 0] = x;
				__bufferData[offset + 1] = y;

				__bufferData[offset + attributeLength + 0] = x2;
				__bufferData[offset + attributeLength + 1] = y2;

				__bufferData[offset + (attributeLength * 2) + 0] = x3;
				__bufferData[offset + (attributeLength * 2) + 1] = y3;

				__bufferData[offset + (attributeLength * 3) + 0] = x3;
				__bufferData[offset + (attributeLength * 3) + 1] = y3;

				__bufferData[offset + (attributeLength * 4) + 0] = x2;
				__bufferData[offset + (attributeLength * 4) + 1] = y2;

				__bufferData[offset + (attributeLength * 5) + 0] = x4;
				__bufferData[offset + (attributeLength * 5) + 1] = y4;

				for (i in 0...6) {
					__bufferData[offset + (attributeLength * i) + 4] = alpha;

					// 4 x 4 matrix
					__bufferData[offset + (attributeLength * i) + 5] = redMultiplier;
					__bufferData[offset + (attributeLength * i) + 10] = greenMultiplier;
					__bufferData[offset + (attributeLength * i) + 15] = blueMultiplier;
					__bufferData[offset + (attributeLength * i) + 20] = alphaMultiplier;

					__bufferData[offset + (attributeLength * i) + 21] = redOffset / 255;
					__bufferData[offset + (attributeLength * i) + 22] = greenOffset / 255;
					__bufferData[offset + (attributeLength * i) + 23] = blueOffset / 255;
					__bufferData[offset + (attributeLength * i) + 24] = alphaOffset / 255;
				}

				__bufferSkipped[i] = false;
			}

			gl.bufferData(GL.ARRAY_BUFFER, __bufferData, GL.DYNAMIC_DRAW);

			__cacheAlpha = worldAlpha;
			__cacheDefaultTileset = defaultTileset;
			__cacheDefaultColorTransform.__copyFrom(defaultColorTransform);
			__bufferDirty = false;
		}

		return __buffer;
	}
	#end

	// Get & Set Methods

	private inline function get_alpha():Float {
		return __data[ALPHA_INDEX + (position * DATA_LENGTH)];
	}

	private inline function set_alpha(value:Float):Float {
		__dirty[ALPHA_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
		return __data[ALPHA_INDEX + (position * DATA_LENGTH)] = value;
	}

	private function get_colorTransform():ColorTransform {
		if (__colorTransform == null)
			__colorTransform = new ColorTransform();
		var i = COLOR_TRANSFORM_INDEX + (position * DATA_LENGTH);
		__colorTransform.redMultiplier = __data[i];
		__colorTransform.greenMultiplier = __data[i + 1];
		__colorTransform.blueMultiplier = __data[i + 2];
		__colorTransform.alphaMultiplier = __data[i + 3];
		__colorTransform.redOffset = __data[i + 4];
		__colorTransform.greenOffset = __data[i + 5];
		__colorTransform.blueOffset = __data[i + 6];
		__colorTransform.alphaOffset = __data[i + 7];
		return __colorTransform;
	}

	private function set_colorTransform(value:ColorTransform):ColorTransform {
		var i = COLOR_TRANSFORM_INDEX + (position * DATA_LENGTH);

		if (value != null) {
			__data[i] = value.redMultiplier;
			__data[i + 1] = value.greenMultiplier;
			__data[i + 2] = value.blueMultiplier;
			__data[i + 3] = value.alphaMultiplier;
			__data[i + 4] = value.redOffset;
			__data[i + 5] = value.greenOffset;
			__data[i + 6] = value.blueOffset;
			__data[i + 7] = value.alphaOffset;
		} else {
			__data[i] = 1;
			__data[i + 1] = 1;
			__data[i + 2] = 1;
			__data[i + 3] = 1;
			__data[i + 4] = 0;
			__data[i + 5] = 0;
			__data[i + 6] = 0;
			__data[i + 7] = 0;
		}

		__dirty[COLOR_TRANSFORM_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
		return value;
	}

	private inline function get_id():Int {
		return Std.int(__data[ID_INDEX + (position * DATA_LENGTH)]);
	}

	private inline function set_id(value:Int):Int {
		__dirty[SOURCE_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
		__data[ID_INDEX + (position * DATA_LENGTH)] = value;
		return value;
	}

	private inline function get_length():Int {
		return __length;
	}

	private function set_length(value:Int):Int {
		__data.length = value * DATA_LENGTH;
		__dirty.length = value * DIRTY_LENGTH;
		__shaders.length = value;
		__tilesets.length = value;
		__visible.length = value;

		if (value > __length) {
			var cachePosition = position;

			for (i in __length...value) {
				__init(i);
			}

			position = cachePosition;
		}

		__length = value;
		return value;
	}

	private function get_matrix():Matrix {
		if (__matrix == null)
			__matrix = new Matrix();
		var i = MATRIX_INDEX + (position * DATA_LENGTH);
		__matrix.a = __data[i];
		__matrix.b = __data[i + 1];
		__matrix.c = __data[i + 2];
		__matrix.d = __data[i + 3];
		__matrix.tx = __data[i + 4];
		__matrix.ty = __data[i + 5];
		return __matrix;
	}

	private function set_matrix(value:Matrix):Matrix {
		var i = MATRIX_INDEX + (position * DATA_LENGTH);

		if (value != null) {
			__data[i] = value.a;
			__data[i + 1] = value.b;
			__data[i + 2] = value.c;
			__data[i + 3] = value.d;
			__data[i + 4] = value.tx;
			__data[i + 5] = value.ty;
		} else {
			__data[i] = 1;
			__data[i + 1] = 0;
			__data[i + 2] = 0;
			__data[i + 3] = 1;
			__data[i + 4] = 0;
			__data[i + 5] = 0;
		}

		__dirty[MATRIX_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
		return value;
	}

	private function get_rect():Rectangle {
		if (__rect == null)
			__rect = new Rectangle();
		var i = RECT_INDEX + (position * DATA_LENGTH);
		__rect.x = __data[i];
		__rect.y = __data[i + 1];
		__rect.width = __data[i + 2];
		__rect.height = __data[i + 3];
		return __rect;
	}

	private function set_rect(value:Rectangle):Rectangle {
		if (value != null) {
			__data[ID_INDEX + (position * DATA_LENGTH)] = -1;
			var i = RECT_INDEX + (position * DATA_LENGTH);
			__data[i] = value.x;
			__data[i + 1] = value.y;
			__data[i + 2] = value.width;
			__data[i + 3] = value.height;
		} else {
			var i = RECT_INDEX + (position * DATA_LENGTH);
			__data[i] = 0;
			__data[i + 1] = 0;
			__data[i + 2] = 0;
			__data[i + 3] = 0;
		}

		__dirty[SOURCE_DIRTY_INDEX + (position * DIRTY_LENGTH)] = true;
		return value;
	}

	private inline function get_shader():Shader {
		return __shaders[position];
	}

	private inline function set_shader(value:Shader):Shader {
		__shaders[position] = value;
		return value;
	}

	private inline function get_tileset():Tileset {
		return __tilesets[position];
	}

	private inline function set_tileset(value:Tileset):Tileset {
		__tilesets[position] = value;
		return value;
	}

	private inline function get_visible():Bool {
		return __visible[position];
	}

	private inline function set_visible(value:Bool):Bool {
		__visible[position] = value;
		return value;
	}
}

private class TileArrayIterator {
	private var cachePosition:Int;
	private var data:TileArray;
	private var position:Int;

	private function new(data:TileArray) {
		this.data = data;
		cachePosition = data.position;
		position = 0;
	}

	public function hasNext():Bool {
		if (position < data.length) {
			return true;
		} else {
			data.position = cachePosition;
			return false;
		}
	}

	public function next():ITile {
		data.position = position++;
		return data;
	}
}
