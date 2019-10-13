package openfl._internal.renderer.opengl;


import lime.utils.Float32Array;
import lime.graphics.opengl.GL;
import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl.display.Graphics;
import openfl.geom.Matrix;

#if gl_stats
import openfl._internal.renderer.opengl.stats.GLStats;
import openfl._internal.renderer.opengl.stats.DrawCallContext;
#end

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.Graphics)


class GLGraphics {
	
	
	private static function isCompatible (graphics:Graphics, parentTransform:Matrix):Bool {
		
		#if !openfl_glgraphics
		return false;
		#end
		
		if (!graphics.__visible || graphics.__commands.length == 0 || parentTransform.b != 0 || parentTransform.c != 0) {
			
			return false;
			
		} else {
			
			var data = new DrawCommandReader (graphics.__commands);
			var bitmap = null;
			
			for (type in graphics.__commands.types) {
				
				switch (type) {
					
					case BEGIN_BITMAP_FILL:
						
						var c = data.readBeginBitmapFill ();
						bitmap = c.bitmap;
					
					case END_FILL:
						
						bitmap = null;
						data.skip (type);
					
					case DRAW_RECT:
						
						if (bitmap != null) {
							
							var c = data.readDrawRect ();
							
							if (c.width != bitmap.width || c.height != bitmap.height) {
								
								data.destroy ();
								return false;
								
							}
							
						} else {
							
							data.skip (type);
							
						}
					
					case MOVE_TO:
						
						data.skip (type);
					
					default:
						
						data.destroy ();
						return false;
					
				}
				
			}
			
			return true;
			
		}
		
	}
	
	
	public static function render (graphics:Graphics, renderSession:RenderSession, parentTransform:Matrix, worldAlpha:Float):Void {
		
		if (!isCompatible (graphics, parentTransform)) {
			
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession);
			#end
			
		} else {
			
			graphics.__update ();
			
			var bounds = graphics.__bounds;
			
			var width = graphics.__width;
			var height = graphics.__height;
			
			if (bounds != null && width >= 1 && height >= 1) {
				
				var data = new DrawCommandReader (graphics.__commands);
				
				var renderer:GLRenderer = cast renderSession.renderer;
				var gl = renderSession.gl;
				
				var shader = renderSession.shaderManager.defaultShader;
				renderSession.shaderManager.setShader (shader);
				
				var bitmap = null;
				var smooth = false;
				
				var positionX = 0.0;
				var positionY = 0.0;
				
				for (type in graphics.__commands.types) {
					
					switch (type) {
						
						case MOVE_TO:
							
							var c = data.readMoveTo ();
							positionX = c.x;
							positionY = c.y;
						
						case END_FILL:
							
							bitmap = null;
						
						case BEGIN_BITMAP_FILL:
							
							var c = data.readBeginBitmapFill ();
							bitmap = c.bitmap;
							smooth = c.smooth;
						
						case DRAW_RECT:
							
							var c = data.readDrawRect ();
							
							if (bitmap != null) {
								
								gl.enableVertexAttribArray (shader.data.aAlpha.index);
								gl.uniformMatrix4fv (shader.data.uMatrix.index, 1, false, renderer.getMatrix (parentTransform));
								
								gl.uniform1i (shader.data.uColorTransform.index, 0);
								
								gl.bindTexture (GL.TEXTURE_2D, bitmap.getTexture (gl).data.glTexture);
								
								//if (renderSession.allowSmoothing && (smooth || renderSession.forceSmoothing)) {
									
									gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
									gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
									
								//} else {
									//
									//gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
									//gl.texParameteri (GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
									//
								//}
								
								gl.bindBuffer (GL.ARRAY_BUFFER, bitmap.getBuffer (gl, worldAlpha, null));
								
								gl.vertexAttribPointer (shader.data.aPosition.index, 3, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
			gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer (shader.data.aAlpha.index, 1, GL.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
			
								gl.drawArrays (GL.TRIANGLE_STRIP, 0, 4);
								
								#if gl_stats
									GLStats.incrementDrawCall (DrawCallContext.STAGE);
								#end
								
							}
						
						default:
							
							data.skip (type);
						
					}
					
				}
				
			}
			
			graphics.__dirty = false;
			
		}
		
	}
	
	
	public static function renderMask (graphics:Graphics, renderSession:RenderSession, parentTransform:Matrix, worldAlpha:Float):Void {
		
		// TODO: Support invisible shapes
		
		#if (js && html5)
		CanvasGraphics.render (graphics, renderSession);
		#end
		
	}
	
	
}