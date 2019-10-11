package lime.utils;


import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GL;
import lime.utils.Log;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class GLUtils {
	
	
	public static function compileShader (source:String, type:Int):GLShader {
		
		var shader = GL.context.createShader (type);
		GL.context.shaderSource (shader, source);
		GL.context.compileShader (shader);
		
		if (GL.context.getShaderParameter (shader, GL.COMPILE_STATUS) == 0) {
			
			var message = switch (type) {
				
				case GL.VERTEX_SHADER: "Error compiling vertex shader";
				case GL.FRAGMENT_SHADER: "Error compiling fragment shader";
				default: "Error compiling unknown shader type";
				
			}
			
			message += "\n" + GL.context.getShaderInfoLog (shader);
			Log.error (message);
			
		}
		
		return shader;
		
	}
	
	
	public static function createProgram (vertexSource:String, fragmentSource:String):GLProgram {
		
		var vertexShader = compileShader (vertexSource, GL.VERTEX_SHADER);
		var fragmentShader = compileShader (fragmentSource, GL.FRAGMENT_SHADER);
		
		var program = GL.context.createProgram ();
		GL.context.attachShader (program, vertexShader);
		GL.context.attachShader (program, fragmentShader);
		GL.context.linkProgram (program);
		
		if (GL.context.getProgramParameter (program, GL.LINK_STATUS) == 0) {
			
			var message = "Unable to initialize the shader program";
			message += "\n" + GL.context.getProgramInfoLog (program);
			Log.error (message);
			
		}
		
		return program;
		
	}
	
	
}