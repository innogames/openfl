package openfl.display;

import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.canvas.CanvasBitmap;
import openfl._internal.renderer.canvas.CanvasDisplayObject;
import openfl._internal.renderer.canvas.CanvasTilemap;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl._internal.renderer.opengl.GLDisplayObject;
import openfl._internal.renderer.opengl.GLTilemap;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.Vector;

@:access(openfl.display.Tile)
@:access(openfl.display.TileArray)
@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Rectangle)
class Tilemap extends DisplayObject {
	public var numTiles(default, null):Int;
	@:beta public var shader:Shader;
	public var tileset(get, set):Tileset;

	public var pixelSnapping(get, set):PixelSnapping;
	public var smoothing:Bool;

	private var __tiles:Vector<Tile>;
	private var __tileset:Tileset;
	private var __tileArray:TileArray;
	private var __tileArrayDirty:Bool;
	private var __height:Int;
	private var __width:Int;

	public function new(width:Int, height:Int, tileset:Tileset = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = true) {
		super();

		__tileset = tileset;

		if (pixelSnapping == null)
			pixelSnapping = PixelSnapping.AUTO;
		__pixelSnapping = pixelSnapping;

		this.smoothing = smoothing;

		__tiles = new Vector();
		numTiles = 0;

		__width = width;
		__height = height;
	}

	public function dispose() {}

	public function addTile(tile:Tile):Tile {
		if (tile == null)
			return null;

		if (tile.parent == this) {
			removeTile(tile);
		}

		__tiles[numTiles] = tile;
		numTiles++;
		tile.parent = this;
		__setRenderDirty();

		return tile;
	}

	public function addTileAt(tile:Tile, index:Int):Tile {
		if (tile == null)
			return null;

		if (tile.parent == this) {
			var cacheLength = __tiles.length;

			removeTile(tile);

			if (cacheLength > __tiles.length) {
				index--;
			}
		}

		__tiles.insertAt(index, tile);
		tile.parent = this;
		__tileArrayDirty = true;
		numTiles++;

		__setRenderDirty();

		return tile;
	}

	public function addTiles(tiles:Array<Tile>):Array<Tile> {
		for (tile in tiles) {
			addTile(tile);
		}

		return tiles;
	}

	public function contains(tile:Tile):Bool {
		return (__tiles.indexOf(tile) > -1);
	}

	public function getTileAt(index:Int):Tile {
		if (index >= 0 && index < numTiles) {
			var tile = __tiles[index];

			if (tile == null && __tileArray != null && index < __tileArray.length) {
				tile = Tile.__fromTileArray(index, __tileArray);
				__tiles[index] = tile;
			}

			return __tiles[index];
		}

		return null;
	}

	public function getTileIndex(tile:Tile):Int {
		for (i in 0...__tiles.length) {
			if (__tiles[i] == tile)
				return i;
		}

		return -1;
	}

	@:beta public function getTiles():TileArray {
		__updateTileArray();

		if (__tileArray == null) {
			__tileArray = new TileArray();
		}

		return __tileArray;
	}

	public function removeTile(tile:Tile):Tile {
		if (tile != null && tile.parent == this) {
			var cacheLength = __tiles.length;

			for (i in 0...__tiles.length) {
				if (__tiles[i] == tile) {
					tile.parent = null;
					__tiles.splice(i, 1);
					break;
				}
			}

			__tileArrayDirty = true;

			if (cacheLength > __tiles.length) {
				numTiles--;
			}

			if (numTiles <= 0 && __tileArray != null) {
				__tileArray.length = 0;
			}

			__setRenderDirty();
		}
		return tile;
	}

	public function removeTileAt(index:Int):Tile {
		if (index >= 0 && index < numTiles) {
			return removeTile(__tiles[index]);
		}

		return null;
	}

	public function removeTiles(beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void {
		if (beginIndex < 0)
			beginIndex = 0;
		if (endIndex > __tiles.length - 1)
			endIndex = __tiles.length - 1;

		var removed = __tiles.splice(beginIndex, endIndex - beginIndex + 1);
		for (tile in removed) {
			tile.parent = null;
		}
		__tileArrayDirty = true;
		numTiles = __tiles.length;

		if (numTiles == 0 && __tileArray != null) {
			__tileArray.length = 0;
		}

		__setRenderDirty();
	}

	@:beta public function setTiles(tileArray:TileArray):Void {
		__tileArray = tileArray;
		numTiles = __tileArray.length;
		__tileArray.__bufferDirty = true;
		__tileArrayDirty = false;
		__tiles.length = 0;
		__setRenderDirty();
	}

	private override function __getBounds(rect:Rectangle, matrix:Matrix):Void {
		var bounds = DisplayObject.__tempBoundsRectangle;
		bounds.setTo(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);

		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);
	}

	private override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject,
			hitTestWhenMouseDisabled:Bool = false):Bool {
		if (!hitObject.visible || __isMask)
			return false;
		if (mask != null && !mask.__hitTestMask(x, y))
			return false;

		__getRenderTransform();

		var px = __renderTransform.__transformInverseX(x, y);
		var py = __renderTransform.__transformInverseY(x, y);

		if (px > 0 && py > 0 && px <= __width && py <= __height) {
			if (stack != null && !interactiveOnly && !hitTestWhenMouseDisabled) {
				stack.push(hitObject);
			}

			return true;
		}

		return false;
	}

	private override function __renderCanvas(renderSession:RenderSession):Void {
		__updateCacheBitmap(renderSession, !__worldColorTransform.__isDefault());

		if (__cacheBitmap != null && !__cacheBitmapRender) {
			CanvasBitmap.render(__cacheBitmap, renderSession);
		} else {
			CanvasDisplayObject.render(this, renderSession);
			CanvasTilemap.render(this, renderSession);
		}
	}

	private override function __renderGL(renderSession:RenderSession):Void {
		__updateCacheBitmap(renderSession, false);

		if (__cacheBitmap != null && !__cacheBitmapRender) {
			GLBitmap.render(__cacheBitmap, renderSession);
		} else {
			GLDisplayObject.render(this, renderSession);
			GLTilemap.render(this, renderSession);
		}
	}

	private override function __renderGLMask(renderSession:RenderSession):Void {
		__updateCacheBitmap(renderSession, false);

		if (__cacheBitmap != null && !__cacheBitmapRender) {
			GLBitmap.renderMask(__cacheBitmap, renderSession);
		} else {
			GLDisplayObject.renderMask(this, renderSession);
			GLTilemap.renderMask(this, renderSession);
		}
	}

	private function __updateTileArray():Void {
		if (__tiles.length > 0) {
			if (__tileArray == null) {
				__tileArray = new TileArray();
			}

			// if (__tileArray.length < numTiles) {
			__tileArray.length = numTiles;
			// }

			var tile:Tile;

			for (i in 0...__tiles.length) {
				tile = __tiles[i];
				if (tile != null) {
					tile.__updateTileArray(i, __tileArray, __tileArrayDirty);
				}
			}
		}

		__tileArrayDirty = false;
	}

	// Get & Set Methods

	private override function get_height():Float {
		return __height * Math.abs(scaleY);
	}

	private override function set_height(value:Float):Float {
		__height = Std.int(value);
		return __height * Math.abs(scaleY);
	}

	private function get_tileset():Tileset {
		return __tileset;
	}

	private function set_tileset(value:Tileset):Tileset {
		__tileArrayDirty = true;
		return __tileset = value;
	}

	private override function get_width():Float {
		return __width * Math.abs(__scaleX);
	}

	private override function set_width(value:Float):Float {
		__width = Std.int(value);
		return __width * Math.abs(__scaleX);
	}
}
