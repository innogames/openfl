package openfl._internal.renderer.opengl;


import lime.utils.Float32Array;
import lime.graphics.opengl.GL;
import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl._internal.renderer.RenderSession;
import openfl.display.DisplayObject;

#if gl_stats
import openfl._internal.renderer.opengl.stats.GLStats;
import openfl._internal.renderer.opengl.stats.DrawCallContext;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.filters.BitmapFilter)
@:access(openfl.geom.ColorTransform)


class GLShape {
	
	
	public static function render (shape:DisplayObject, renderSession:RenderSession):Void {
		
		if (!shape.__renderable || shape.__worldAlpha <= 0) return;
		
		var graphics = shape.__graphics;
		
		if (graphics != null) {
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession);
			#end
			
			if (graphics.__bitmap != null && graphics.__visible) {
				
				renderSession.maskManager.pushObject (shape);
				renderSession.batcher.render(graphics.__getBatchQuad(renderSession, shape.__worldAlpha, shape.__worldColorTransform, shape.__worldBlendMode));
				renderSession.maskManager.popObject (shape);
				
			}
			
		}
		
	}
	
	
	public static function renderMask (shape:DisplayObject, renderSession:RenderSession):Void {
		
		var graphics = shape.__graphics;
		
		if (graphics != null) {
			
			// TODO: Support invisible shapes
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession);
			#end
			
			var bounds = graphics.__bounds;
			
			if (graphics.__bitmap != null) {
				
				var renderer:GLRenderer = cast renderSession.renderer;
				var gl = renderSession.gl;
				
				var shader = (cast renderSession.maskManager:GLMaskManager).maskShader;
				
				//var shader = renderSession.shaderManager.initShader (shape.shader);
				renderSession.shaderManager.setShader (shader);
				
				shader.data.uImage0.input = graphics.__bitmap;
				shader.data.uImage0.smoothing = renderSession.allowSmoothing;
				shader.data.uMatrix.value = renderer.getMatrix (graphics.__worldTransform);
				
				var vaoRendered = GLVAORenderHelper.renderMask (shape, renderSession, shader, graphics.__bitmap);
				
				if (vaoRendered) return;
				
				renderSession.shaderManager.updateShader (shader);
				
				gl.bindBuffer (GL.ARRAY_BUFFER, graphics.__bitmap.getBuffer (gl, shape.__worldAlpha, shape.__worldColorTransform));
				
				gl.vertexAttribPointer (shader.data.aPosition.index, 3, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
				
				gl.drawArrays (GL.TRIANGLE_STRIP, 0, 4);
				
				#if gl_stats
					GLStats.incrementDrawCall (DrawCallContext.STAGE);
				#end
				
			}
			
		}
		
	}
	
	
}