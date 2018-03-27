package openfl._internal.renderer.opengl;


#if gl_stats
import openfl._internal.renderer.opengl.stats.GLStats;
import openfl._internal.renderer.opengl.stats.DrawCallContext;
#end
import openfl.display.OpenGLRenderer;
import openfl.display.BitmapData;
import haxe.io.Float32Array;
import openfl.display.Shader;
import openfl.display.DisplayObject;
import lime.graphics.GLRenderContext;


/**
*  GLVAORenderHelper is a helper class facilitating a GL rendering using VertexArrayObjects. Since VertexArrayObjects are 
*  supported in Webgl2 and as an extension in Webgl1, in case they are not supported there is a fallback mechanism 
*  using usual non-VertexArrayObjects GL rendering.
**/
@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.geom.ColorTransform)
@:access(openfl.display.Shader)


class GLVAORenderHelper {
	
	
	private static inline function __enableVertexAttribArray (gl:GLRenderContext, shader: Shader):Void {
		
		gl.enableVertexAttribArray (shader.data.openfl_Position.index);
		gl.enableVertexAttribArray (shader.data.openfl_TexCoord.index);
	}
	
	
	public static inline function renderDO (displayObject:DisplayObject, renderer:OpenGLRenderer, bitmapData: BitmapData, isMask: Bool = false):Bool {
		
		var gl = renderer.gl;
		var vaoContext = renderer.vaoContext;
		
		if (vaoContext != null) {
			
			var shaderManager:GLShaderManager = cast renderer.shaderManager;
			var shader = shaderManager.currentShader;
			
			shader.__skipEnableVertexAttribArray = true;
			shaderManager.updateShader ();
			shader.__skipEnableVertexAttribArray = false;
			
			var vao: Dynamic = isMask ? displayObject.__vaoMask : displayObject.__vao;
			var hasVAO: Bool = vao != null;
			if (!hasVAO) {
				
				if (isMask) {
					
					displayObject.__vaoMask = vaoContext.createVertexArray ();
					vao = displayObject.__vaoMask;
					
				} else {
					
					displayObject.__vao = vaoContext.createVertexArray ();
					vao = displayObject.__vao;
				}
				
			}
			
			vaoContext.bindVertexArray (vao);
			if (!hasVAO || bitmapData.isBufferDirty (gl)) {
				
				__enableVertexAttribArray (gl, shader);
				bitmapData.getBuffer (gl);
				__setVertexAttribPointer (gl, shader);
				
			} 
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
			
			renderer.filterManager.popObject (displayObject);
			renderer.maskManager.popObject (displayObject);
			
			vaoContext.bindVertexArray (null);
			
			return true;
		}
		
		return false;
		
	}
	
	private static inline function __setVertexAttribPointer (gl:GLRenderContext, shader: Shader):Void {
		
		gl.vertexAttribPointer (shader.data.openfl_Position.index, 3, gl.FLOAT, false, 14 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer (shader.data.openfl_TexCoord.index, 2, gl.FLOAT, false, 14 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		
	}
	
	
}
