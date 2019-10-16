package openfl._internal.stage3D;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLProgram;
import lime.utils.Log;
import openfl.errors.IllegalOperationError;

class GLUtils {
	private static var debug = false;

	public static function compileShader (context:GL, source:String, type:Int):GLShader {
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
	
	
	public static function createProgram (context:GL, vertexSource:String, fragmentSource:String):GLProgram {
		
		var vertexShader = compileShader (context, vertexSource, GL.VERTEX_SHADER);
		var fragmentShader = compileShader (context, fragmentSource, GL.FRAGMENT_SHADER);
		
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
	
	
	public static function checkGLError(gl:GL):Void {
		if (!debug)
			return;

		var error = gl.getError();

		if (error != GL.NO_ERROR) {
			var errorText = switch (error) {
				case GL.NO_ERROR:
					"GL_NO_ERROR";
				case GL.INVALID_ENUM:
					"GL_INVALID_ENUM";
				case GL.INVALID_OPERATION:
					"GL_INVALID_OPERATION";
				case GL.INVALID_FRAMEBUFFER_OPERATION:
					"GL_INVALID_FRAMEBUFFER_OPERATION";
				case GL.INVALID_VALUE:
					"GL_INVALID_VALUE";
				case GL.OUT_OF_MEMORY:
					"GL_OUT_OF_MEMORY";
				default:
					Std.string(error);
			};

			throw new IllegalOperationError("Error calling openGL api. Error: " + errorText + "\n");
		}
	}
}
