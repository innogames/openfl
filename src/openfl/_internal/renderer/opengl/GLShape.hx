package openfl._internal.renderer.opengl;

import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl.display.DisplayObject;
#if gl_stats
import openfl._internal.renderer.opengl.stats.DrawCallContext;
import openfl._internal.renderer.opengl.stats.GLStats;
#end

@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Graphics)
@:access(openfl.filters.BitmapFilter)
@:access(openfl.geom.ColorTransform)
class GLShape {
	public static function render(shape:DisplayObject, renderSession:GLRenderSession):Void {
		if (!shape.__renderable || shape.__worldAlpha <= 0)
			return;

		var graphics = shape.__graphics;

		if (graphics != null) {
			CanvasGraphics.render(graphics, renderSession.pixelRatio, renderSession.allowSmoothing);

			if (graphics.__bitmap != null && graphics.__visible) {
				renderSession.maskManager.pushObject(shape);
				renderSession.batcher.render(graphics.__getBatchQuad(renderSession, shape.__worldAlpha, shape.__worldColorTransform, shape.__worldBlendMode));
				renderSession.maskManager.popObject(shape);
			}
		}
	}

	public static function renderMask(shape:DisplayObject, renderSession:GLRenderSession):Void {
		var graphics = shape.__graphics;

		if (graphics != null) {
			// TODO: Support invisible shapes
			CanvasGraphics.render(graphics, renderSession.pixelRatio, renderSession.allowSmoothing);

			if (graphics.__bitmap != null) {
				var renderer = renderSession.renderer;
				var gl = renderSession.gl;

				var shader = (cast renderSession.maskManager : GLMaskManager).maskShader;

				// var shader = renderSession.shaderManager.initShader (shape.shader);
				renderSession.shaderManager.setShader(shader);

				shader.data.uImage0.input = graphics.__bitmap;
				shader.data.uImage0.smoothing = renderSession.allowSmoothing;
				shader.data.uMatrix.value = renderer.getMatrix(graphics.__worldTransform);

				#if vertex_array_object
				var vaoRendered = GLVAORenderHelper.renderMask(shape, renderSession, shader, graphics.__bitmap);
				if (vaoRendered)
					return;
				#end

				renderSession.shaderManager.updateShader(shader);

				gl.bindBuffer(GL.ARRAY_BUFFER, graphics.__bitmap.getBuffer(gl, shape.__worldAlpha, shape.__worldColorTransform));

				gl.vertexAttribPointer(shader.data.aPosition.index, 3, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
				gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT,
					3 * Float32Array.BYTES_PER_ELEMENT);

				gl.drawArrays(GL.TRIANGLE_STRIP, 0, 4);

				#if gl_stats
				GLStats.incrementDrawCall(DrawCallContext.STAGE);
				#end
			}
		}
	}
}
