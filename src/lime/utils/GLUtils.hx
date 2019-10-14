package lime.utils;


import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GL;
import lime._backend.html5.HTML5Renderer.context;
import lime.utils.Log;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class GLUtils {
	
	
	public static function compileShader (source:String, type:Int):GLShader {
		var shader = context.createShader (type);
		context.shaderSource (shader, source);
		context.compileShader (shader);
		
		if (context.getShaderParameter (shader, GL.COMPILE_STATUS) == 0) {
			
			var message = switch (type) {
				
				case GL.VERTEX_SHADER: "Error compiling vertex shader";
				case GL.FRAGMENT_SHADER: "Error compiling fragment shader";
				default: "Error compiling unknown shader type";
				
			}
			
			message += "\n" + context.getShaderInfoLog (shader);
			Log.error (message);
			
		}
		
		return shader;
		
	}
	
	
	public static function createProgram (vertexSource:String, fragmentSource:String):GLProgram {
		
		var vertexShader = compileShader (vertexSource, GL.VERTEX_SHADER);
		var fragmentShader = compileShader (fragmentSource, GL.FRAGMENT_SHADER);
		
		var program = context.createProgram ();
		context.attachShader (program, vertexShader);
		context.attachShader (program, fragmentShader);
		context.linkProgram (program);
		
		if (context.getProgramParameter (program, GL.LINK_STATUS) == 0) {
			
			var message = "Unable to initialize the shader program";
			message += "\n" + context.getProgramInfoLog (program);
			Log.error (message);
			
		}
		
		return program;
		
	}
	
	
}