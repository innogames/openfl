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
@:access(openfl.display.OpenGLRenderer)
@:access(openfl.display.DisplayObject)
@:access(openfl.display.BitmapData)
@:access(openfl.display.Shader)


class GLVAORenderHelper {
	
	
	private static inline function __enableVertexAttribArray (gl:GLRenderContext, shader: Shader):Void {
		
		gl.enableVertexAttribArray (shader.__position.index);
		gl.enableVertexAttribArray (shader.__textureCoord.index);
		
	}
	
	
	public static inline function renderDO (renderer:OpenGLRenderer, shader:Shader, bitmapData: BitmapData):Bool {
		
		var gl = renderer.gl;
		var vaoContext = renderer.__vaoContext;
		
		if (vaoContext != null) {
			
			shader.__skipEnableVertexAttribArray = true;
			renderer.updateShader ();
			shader.__skipEnableVertexAttribArray = false;
			
			var hasVAO: Bool = bitmapData.__vao != null;
			if (!hasVAO) {
				
				bitmapData.__vao = vaoContext.createVertexArray ();
				
			}
			
			vaoContext.bindVertexArray (bitmapData.__vao);
			if (!hasVAO) {
				
				__enableVertexAttribArray (gl, shader);
				bitmapData.getBuffer (gl);
				__setVertexAttribPointer (gl, shader);
				
			} 
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
			
			vaoContext.bindVertexArray (null);
			
			return true;
		}
		
		return false;
		
	}
	
	public static inline function renderMask (renderer:OpenGLRenderer, shader:Shader, bitmapData: BitmapData):Bool {
		
		var gl = renderer.gl;
		var vaoContext = renderer.__vaoContext;
		
		if (vaoContext != null) {
			
			shader.__skipEnableVertexAttribArray = true;
			renderer.updateShader ();
			shader.__skipEnableVertexAttribArray = false;
			
			var hasVAO: Bool = bitmapData.__vaoMask != null;
			if (!hasVAO) {
				
				bitmapData.__vaoMask = vaoContext.createVertexArray ();
				
			}
			
			vaoContext.bindVertexArray (bitmapData.__vaoMask);
			if (!hasVAO) {
				
				gl.enableVertexAttribArray (shader.__position.index);
				gl.enableVertexAttribArray (shader.__textureCoord.index);
				
				bitmapData.getBuffer (gl);
				
				__setVertexAttribPointer (gl, shader);
				
			} 
			
			gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);
			
			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
			
			vaoContext.bindVertexArray (null);
			
			return true;
			
		} 
		
		return false;
		
	}
	
	
	private static inline function __setVertexAttribPointer (gl:GLRenderContext, shader: Shader):Void {
		
		if (shader.__position != null) gl.vertexAttribPointer (shader.__position.index, 3, gl.FLOAT, false, 14 * Float32Array.BYTES_PER_ELEMENT, 0);
		if (shader.__textureCoord != null) gl.vertexAttribPointer (shader.__textureCoord.index, 2, gl.FLOAT, false, 14 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		
	}
	
	
}
