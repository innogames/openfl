package openfl.display;


import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.canvas.CanvasBitmap;
import openfl._internal.renderer.opengl.GLBitmap;
import openfl._internal.renderer.opengl.batcher.BlendMode as BatcherBlendMode;
import openfl._internal.renderer.opengl.batcher.Quad;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

#if (js && html5)
import js.html.ImageElement;
#end

@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.geom.ColorTransform)
@:access(openfl.geom.Rectangle)
class Bitmap extends DisplayObject {
	
	
	public var bitmapData (get, set):BitmapData;
	public var pixelSnapping (get, set):PixelSnapping;
	public var smoothing:Bool;
	
	#if (js && html5)
	private var __image:ImageElement;
	#end
	
	private var __bitmapData:BitmapData;
	private var __bitmapDataUserPrev:Bitmap;
	private var __bitmapDataUserNext:Bitmap;
	
	var __batchQuad:Quad;
	var __batchQuadDirty:Bool = true;
	
	
	public function new (bitmapData:BitmapData = null, pixelSnapping:PixelSnapping = null, smoothing:Bool = false) {
		
		super ();
		
		__bitmapData = bitmapData;

		if (pixelSnapping == null) pixelSnapping = PixelSnapping.AUTO;
		__pixelSnapping = pixelSnapping;

		this.smoothing = smoothing;
		
	}
	
	override function __setStageReference(stage:Stage) {
		
		this.stage = stage;
		
		if (stage == null) {
			__unlinkFromBitmapData(__bitmapData);
		} else {
			__linkToBitmapData(__bitmapData);
		}
		
	}
	
	private override function __cleanup ():Void {
		
		super.__cleanup ();
		
		if (__bitmapData != null) {
			
			__bitmapData.__cleanup ();
			
		}
		
		if (__batchQuad != null) {
			
			Quad.pool.release (__batchQuad);
			__batchQuad = null;
			
		}
		
	}
	
	private override function __getBounds (rect:Rectangle, matrix:Matrix):Void {
		
		if (__bitmapData != null) {
			
			var bounds = DisplayObject.__tempBoundsRectangle;
			__bitmapData.rect.__transform (bounds, matrix);
			rect.__expand (bounds.x, bounds.y, bounds.width, bounds.height);
			
		}
		
	}
	
	
	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject, hitTestWhenMouseDisabled:Bool = false):Bool {
		
		if (!hitObject.visible || __isMask || __bitmapData == null) return false;
		if (mask != null && !mask.__hitTestMask (x, y)) return false;
		
		__getRenderTransform ();
		
		var px = __renderTransform.__transformInverseX (x, y);
		var py = __renderTransform.__transformInverseY (x, y);
		
		if (px > 0 && py > 0 && px <= __bitmapData.width && py <= __bitmapData.height) {
			
			if (__scrollRect != null && !__scrollRect.contains (px, py)) {
				
				return false;
				
			}
			
			if (stack != null && !interactiveOnly && !hitTestWhenMouseDisabled) {
				
				stack.push (hitObject);
				
			}
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	private override function __hitTestMask (x:Float, y:Float):Bool {
		
		if (__bitmapData == null) return false;
		
		__getRenderTransform ();
		
		var px = __renderTransform.__transformInverseX (x, y);
		var py = __renderTransform.__transformInverseY (x, y);
		
		if (px > 0 && py > 0 && px <= __bitmapData.width && py <= __bitmapData.height) {
			
			return true;
			
		}
		
		return false;
		
	}
	
	
	private override function __renderCanvas (renderSession:RenderSession):Void {
		
		__updateCacheBitmap (renderSession, !__worldColorTransform.__isDefault ());
		
		if (__cacheBitmap != null && !__cacheBitmapRender) {
			
			CanvasBitmap.render (__cacheBitmap, renderSession);
			
		} else {
			
			CanvasBitmap.render (this, renderSession);
			
		}
		
	}
	
	
	private override function __renderCanvasMask (renderSession:RenderSession):Void {
		
		renderSession.context.rect (0, 0, __bitmapData.width, __bitmapData.height);
		
	}
	
	
	function __getBatchQuad (renderSession:RenderSession):Quad {
		
		if (__batchQuadDirty) {
			if (__batchQuad == null) {
				__batchQuad = Quad.pool.get ();
			}
			
			var snapToPixel = renderSession.roundPixels || __snapToPixel ();
			var transform = renderSession.renderer.getDisplayTransformTempMatrix (__renderTransform, snapToPixel);
			bitmapData.__fillBatchQuad (transform, __batchQuad.vertexData);
			__batchQuad.texture = __bitmapData.getTexture (renderSession.gl);
			__batchQuadDirty = false;
		}
		
		__batchQuad.setup(__worldAlpha, __worldColorTransform, BatcherBlendMode.fromOpenFLBlendMode(__worldBlendMode), smoothing);
		
		return __batchQuad;
		
	}

	override function __updateTransforms ():Void {
		
		super.__updateTransforms ();
		__batchQuadDirty = true;
		
	}
	
	
	private override function __renderGL (renderSession:RenderSession):Void {
		
		__updateCacheBitmap (renderSession, false);
		
		if (__cacheBitmap != null && !__cacheBitmapRender) {
			
			GLBitmap.render (__cacheBitmap, renderSession);
			
		} else {
			
			GLBitmap.render (this, renderSession);
			
		}
		
	}
	
	
	private override function __renderGLMask (renderSession:RenderSession):Void {
		
		__updateCacheBitmap (renderSession, false);
		
		if (__cacheBitmap != null && !__cacheBitmapRender) {
			
			GLBitmap.renderMask (__cacheBitmap, renderSession);
			
		} else {
			
			GLBitmap.renderMask (this, renderSession);
			
		}
		
	}
	
	
	private override function __updateCacheBitmap (renderSession:RenderSession, force:Bool):Bool {
		
		if (!force && !__hasFilters () && __cacheBitmap == null) return false;
		return super.__updateCacheBitmap (renderSession, force);
		
	}
	
	
	override function __forceRenderDirty() {
		
		super.__forceRenderDirty ();
		
		__batchQuadDirty = true;
		
	}
	
	
	// Get & Set Methods
	
	
	
	
	private function get_bitmapData ():BitmapData {
		
		return __bitmapData;
		
	}
	
	inline function __unlinkFromBitmapData(b:BitmapData) {
		if (b != null) {
			if (b.__usersHead == this) {
				b.__usersHead = __bitmapDataUserNext;
			}
			if (b.__usersTail == this) {
				b.__usersTail = __bitmapDataUserPrev;
			}
			if (__bitmapDataUserPrev != null) {
				__bitmapDataUserPrev.__bitmapDataUserNext = __bitmapDataUserNext;
			}
			if (__bitmapDataUserNext != null) {
				__bitmapDataUserNext.__bitmapDataUserPrev = __bitmapDataUserPrev;
			}
			__bitmapDataUserPrev = __bitmapDataUserNext = null;
		}
	}
	
	inline function __linkToBitmapData(b:BitmapData) {
		if (b != null) {
			if (b.__usersHead == null) {
				b.__usersHead = b.__usersTail = this;
			} else {
				b.__usersTail.__bitmapDataUserNext = this;
				__bitmapDataUserPrev = b.__usersTail;
				b.__usersTail = this;
			}
		}
	}
	
	
	inline function __setBitmapDataDirty () {
		
		__batchQuadDirty = true;
		__setRenderDirty ();
		
	}
	
	
	private function set_bitmapData (value:BitmapData):BitmapData {
		
		if (stage != null && value != __bitmapData) {
			__unlinkFromBitmapData(__bitmapData);
			__linkToBitmapData(value);
		}
		
		__bitmapData = value;
		smoothing = false;
		
		__setBitmapDataDirty ();
		
		if (__hasFilters ()) {
			
			//__updateFilters = true;
			
		}
		
		return __bitmapData;
		
	}
	
	
	private override function get_height ():Float {
		
		if (__bitmapData != null) {
			
			return __bitmapData.height * Math.abs (scaleY);
			
		}
		
		return 0;
		
	}
	
	
	private override function set_height (value:Float):Float {
		
		if (__bitmapData != null) {
			
			if (value != __bitmapData.height * __scaleY) {
				
				__setRenderDirty ();
				scaleY = value / __bitmapData.height;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
	private override function get_width ():Float {
		
		if (__bitmapData != null) {
			
			return __bitmapData.width * Math.abs (__scaleX);
			
		}
		
		return 0;
		
	}
	
	
	private override function set_width (value:Float):Float {
		
		if (__bitmapData != null) {
			
			if (value != __bitmapData.width * __scaleX) {
				
				__setRenderDirty ();
				scaleX = value / __bitmapData.width;
				
			}
			
			return value;
			
		}
		
		return 0;
		
	}
	
	
}