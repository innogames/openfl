package openfl._internal.stage3D.opengl;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import lime.utils.Log;
import openfl._internal.renderer.opengl.GLRenderSession;
import openfl._internal.stage3D.AGALConverter;
import openfl._internal.stage3D.GLUtils;
import openfl._internal.stage3D.SamplerState;
import openfl.display3D.Context3D;
import openfl.display3D.Program3D;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.utils.ByteArray;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.Program3D)
class GLProgram3D {
	private static var program:Program3D;
	private static var renderSession:GLRenderSession;

	public static function dispose(program:Program3D, renderSession:GLRenderSession):Void {
		GLProgram3D.program = program;
		GLProgram3D.renderSession = renderSession;

		__deleteShaders();
	}

	public static function flushUniform(uniform:Uniform, gl:GLRenderContext):Void {
		var index:Int = uniform.regIndex * 4;
		switch (uniform.type) {
			case GL.FLOAT_MAT2:
				gl.uniformMatrix2fv(uniform.location, false, __getUniformRegisters(uniform, index, uniform.size * 2 * 2));
			case GL.FLOAT_MAT3:
				gl.uniformMatrix3fv(uniform.location, false, __getUniformRegisters(uniform, index, uniform.size * 3 * 3));
			case GL.FLOAT_MAT4:
				gl.uniformMatrix4fv(uniform.location, false, __getUniformRegisters(uniform, index, uniform.size * 4 * 4));
			case GL.FLOAT_VEC2:
				gl.uniform2fv(uniform.location, __getUniformRegisters(uniform, index, uniform.regCount * 2));
			case GL.FLOAT_VEC3:
				gl.uniform3fv(uniform.location, __getUniformRegisters(uniform, index, uniform.regCount * 3));
			case GL.FLOAT_VEC4:
				gl.uniform4fv(uniform.location, __getUniformRegisters(uniform, index, uniform.regCount * 4));
			default:
				gl.uniform4fv(uniform.location, __getUniformRegisters(uniform, index, uniform.regCount * 4));
		}

		GLUtils.checkGLError(gl);
	}

	public static function setPositionScale(program:Program3D, renderSession:GLRenderSession, positionScale:Float32Array):Void {
		var gl = renderSession.gl;
		gl.uniform4fv(program.__positionScale.location, positionScale);
		GLUtils.checkGLError(gl);
	}

	public static function upload(program:Program3D, renderSession:GLRenderSession, vertexProgram:ByteArray, fragmentProgram:ByteArray):Void {
		GLProgram3D.program = program;
		GLProgram3D.renderSession = renderSession;

		// var samplerStates = new Vector<SamplerState> (Context3D.MAX_SAMPLERS);
		var samplerStates = new Array<SamplerState>();

		var glslVertex = AGALConverter.convertToGLSL(renderSession.gl, vertexProgram, null);
		var glslFragment = AGALConverter.convertToGLSL(renderSession.gl, fragmentProgram, samplerStates);

		__uploadFromGLSL(glslVertex, glslFragment);

		for (i in 0...samplerStates.length) {
			program.__samplerStates[i] = samplerStates[i];
		}
	}

	public static function use(program:Program3D, renderSession:GLRenderSession):Void {
		var gl = renderSession.gl;

		gl.useProgram(program.__programID);
		GLUtils.checkGLError(gl);

		program.__vertexUniformMap.markAllDirty();
		program.__fragmentUniformMap.markAllDirty();

		for (sampler in program.__samplerUniforms) {
			if (sampler.regCount == 1) {
				gl.uniform1i(sampler.location, sampler.regIndex);
				GLUtils.checkGLError(gl);
			} else {
				throw new IllegalOperationError("!!! TODO: uniform location on webgl");

				/*
					TODO: Figure out +i on Webgl.
					// sampler array?
					for(i in 0...sampler.regCount) {
						gl.uniform1i(sampler.location + i, sampler.regIndex + i);
						GLUtils.checkGLError (gl);
					}
				 */
			}
		}

		for (sampler in program.__alphaSamplerUniforms) {
			if (sampler.regCount == 1) {
				gl.uniform1i(sampler.location, sampler.regIndex);
				GLUtils.checkGLError(gl);
			} else {
				throw new IllegalOperationError("!!! TODO: uniform location on webgl");

				/*
					TODO: Figure out +i on Webgl.
					// sampler array?
					for(i in 0...sampler.regCount) {
						gl.uniform1i(sampler.location + i, sampler.regIndex + i);
						GLUtils.checkGLError (gl);
					}
				 */
			}
		}
	}

	private static function __buildUniformList():Void {
		var gl = renderSession.gl;

		program.__uniforms.clear();
		program.__samplerUniforms.clear();
		program.__alphaSamplerUniforms.clear();

		program.__samplerUsageMask = 0;

		var numActive = 0;
		numActive = gl.getProgramParameter(program.__programID, GL.ACTIVE_UNIFORMS);
		GLUtils.checkGLError(gl);

		var vertexUniforms = new List<Uniform>();
		var fragmentUniforms = new List<Uniform>();

		for (i in 0...numActive) {
			var info = gl.getActiveUniform(program.__programID, i);
			var name = info.name;
			var size = info.size;
			var uniformType = info.type;
			GLUtils.checkGLError(gl);

			var uniform = new Uniform(gl);
			uniform.name = name;
			uniform.size = size;
			uniform.type = uniformType;

			uniform.location = gl.getUniformLocation(program.__programID, uniform.name);
			GLUtils.checkGLError(gl);

			var indexBracket = uniform.name.indexOf('[');

			if (indexBracket >= 0) {
				uniform.name = uniform.name.substring(0, indexBracket);
			}

			switch (uniform.type) {
				case GL.FLOAT_MAT2:
					uniform.regCount = 2;
				case GL.FLOAT_MAT3:
					uniform.regCount = 3;
				case GL.FLOAT_MAT4:
					uniform.regCount = 4;
				default:
					uniform.regCount = 1;
			}

			uniform.regCount *= uniform.size;

			program.__uniforms.add(uniform);

			if (uniform.name == "vcPositionScale") {
				program.__positionScale = uniform;
			} else if (StringTools.startsWith(uniform.name, "vc")) {
				uniform.regIndex = Std.parseInt(uniform.name.substring(2));
				uniform.regData = program.__context.__vertexConstants;
				vertexUniforms.add(uniform);
			} else if (StringTools.startsWith(uniform.name, "fc")) {
				uniform.regIndex = Std.parseInt(uniform.name.substring(2));
				uniform.regData = program.__context.__fragmentConstants;
				fragmentUniforms.add(uniform);
			} else if (StringTools.startsWith(uniform.name, "sampler") && !StringTools.endsWith(uniform.name, "_alpha")) {
				uniform.regIndex = Std.parseInt(uniform.name.substring(7));
				program.__samplerUniforms.add(uniform);

				for (reg in 0...uniform.regCount) {
					program.__samplerUsageMask |= (1 << (uniform.regIndex + reg));
				}
			} else if (StringTools.startsWith(uniform.name, "sampler") && StringTools.endsWith(uniform.name, "_alpha")) {
				var len = uniform.name.indexOf("_") - 7;
				uniform.regIndex = Std.parseInt(uniform.name.substring(7, 7 + len)) + 4;
				program.__alphaSamplerUniforms.add(uniform);
			}

			if (Log.level == LogLevel.VERBOSE) {
				trace('${i} name:${uniform.name} type:${uniform.type} size:${uniform.size} location:${uniform.location}');
			}
		}

		program.__vertexUniformMap = new UniformMap(Lambda.array(vertexUniforms));
		program.__fragmentUniformMap = new UniformMap(Lambda.array(fragmentUniforms));
	}

	private static function __deleteShaders():Void {
		var gl = renderSession.gl;

		if (program.__programID != null) {
			// this causes an exception EntryPoIntNotFound ..
			// gl.DeleteProgram (1, ref __programID  );
			program.__programID = null;
		}

		if (program.__vertexShaderID != null) {
			gl.deleteShader(program.__vertexShaderID);
			GLUtils.checkGLError(gl);
			program.__vertexShaderID = null;
		}

		if (program.__fragmentShaderID != null) {
			gl.deleteShader(program.__fragmentShaderID);
			GLUtils.checkGLError(gl);
			program.__fragmentShaderID = null;
		}

		// if (__memUsage != 0) {

		// 	__context.__statsDecrement (Context3D.Context3DTelemetry.COUNT_PROGRAM);
		// 	__context.__statsSubtract (Context3D.Context3DTelemetry.MEM_PROGRAM, __memUsage);
		// 	__memUsage = 0;

		// }
	}

	private static inline function __getUniformRegisters(uniform:Uniform, index:Int, size:Int):Float32Array {
		return uniform.regData.subarray(index, index + size);
	}

	private static function __uploadFromGLSL(vertexShaderSource:String, fragmentShaderSource:String):Void {
		var gl = renderSession.gl;

		__deleteShaders();

		if (Log.level == LogLevel.VERBOSE) {
			Log.info(vertexShaderSource);
			Log.info(fragmentShaderSource);
		}

		program.__vertexSource = vertexShaderSource;
		program.__fragmentSource = fragmentShaderSource;

		program.__vertexShaderID = gl.createShader(GL.VERTEX_SHADER);
		gl.shaderSource(program.__vertexShaderID, vertexShaderSource);
		GLUtils.checkGLError(gl);

		gl.compileShader(program.__vertexShaderID);
		GLUtils.checkGLError(gl);

		var shaderCompiled = gl.getShaderParameter(program.__vertexShaderID, GL.COMPILE_STATUS);

		GLUtils.checkGLError(gl);

		if (shaderCompiled == 0) {
			var vertexInfoLog = gl.getShaderInfoLog(program.__vertexShaderID);

			if (vertexInfoLog != null && vertexInfoLog.length != 0) {
				trace('vertex: ${vertexInfoLog}');
			}

			throw new Error("Error compiling vertex shader: " + vertexInfoLog);
		}

		program.__fragmentShaderID = gl.createShader(GL.FRAGMENT_SHADER);
		gl.shaderSource(program.__fragmentShaderID, fragmentShaderSource);
		GLUtils.checkGLError(gl);

		gl.compileShader(program.__fragmentShaderID);
		GLUtils.checkGLError(gl);

		var fragmentCompiled = gl.getShaderParameter(program.__fragmentShaderID, GL.COMPILE_STATUS);

		if (fragmentCompiled == 0) {
			var fragmentInfoLog = gl.getShaderInfoLog(program.__fragmentShaderID);

			if (fragmentInfoLog != null && fragmentInfoLog.length != 0) {
				trace('fragment: ${fragmentInfoLog}');
			}

			throw new Error("Error compiling fragment shader: " + fragmentInfoLog);
		}

		program.__programID = gl.createProgram();
		gl.attachShader(program.__programID, program.__vertexShaderID);
		GLUtils.checkGLError(gl);

		gl.attachShader(program.__programID, program.__fragmentShaderID);
		GLUtils.checkGLError(gl);

		for (i in 0...Context3D.MAX_ATTRIBUTES) {
			var name = "va" + i;

			if (vertexShaderSource.indexOf(" " + name) != -1) {
				gl.bindAttribLocation(program.__programID, i, name);
			}
		}

		gl.linkProgram(program.__programID);

		var infoLog:String = gl.getProgramInfoLog(program.__programID);

		if (infoLog != null && infoLog.length != 0 && StringTools.trim(infoLog) != "") {
			trace('program: ${infoLog}');
		}

		__buildUniformList();

		// __memUsage = 1; // TODO, figure out a way to get this
		// __context.__statsIncrement (Context3D.Context3DTelemetry.COUNT_PROGRAM);
		// __context.__statsAdd (Context3D.Context3DTelemetry.MEM_PROGRAM, __memUsage);
	}
}
