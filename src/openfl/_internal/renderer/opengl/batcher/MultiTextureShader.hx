package openfl._internal.renderer.opengl.batcher;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.Log;

class MultiTextureShader {
	var program:GLProgram;
	var gl:GLRenderContext;

	public var positionScale(default, null):Float32Array;

	public var aVertexPosition(default, null):Int;
	public var aTextureCoord(default, null):Int;
	public var aColorOffset(default, null):Int;
	public var aColorMultiplier(default, null):Int;
	public var aPremultipliedAlpha(default, null):Int;

	var uProjMatrix:GLUniformLocation;
	var uPositionScale:GLUniformLocation;

	// x, y, u, v, alpha, colorMult, colorOfs
	public static inline var floatsPerVertex = 2 + 2 + 4 + 4 + 1;

	public function new(gl:GLRenderContext) {
		this.gl = gl;

		program = createProgram(gl, vsSource, fsSource);
		if (program == null) {
			throw "Could not compile a multi-texture shader for any number of textures, something must be horribly broken!";
		}
		this.positionScale = new Float32Array([1.0, 1.0, 1.0, 1.0]);

		aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
		aTextureCoord = gl.getAttribLocation(program, 'aTextureCoord');
		aColorOffset = gl.getAttribLocation(program, 'aColorOffset');
		aColorMultiplier = gl.getAttribLocation(program, 'aColorMultiplier');
		aPremultipliedAlpha = gl.getAttribLocation(program, 'aPremultipliedAlpha');
		uProjMatrix = gl.getUniformLocation(program, "uProjMatrix");
		uPositionScale = gl.getUniformLocation(program, "uPostionScale");

		gl.useProgram(program);
		gl.uniform1i(gl.getUniformLocation(program, 'uSampler'), 0);
	}

	public function enable(projectionMatrix:Float32Array) {
		gl.useProgram(program);

		gl.enableVertexAttribArray(aVertexPosition);
		gl.enableVertexAttribArray(aTextureCoord);
		gl.enableVertexAttribArray(aColorOffset);
		gl.enableVertexAttribArray(aColorMultiplier);
		gl.enableVertexAttribArray(aPremultipliedAlpha);

		gl.uniformMatrix4fv(uProjMatrix, false, projectionMatrix);
		gl.uniform4fv(uPositionScale, positionScale);
	}

	static function compileShader(gl:GLRenderContext, source:String, type:Int):Null<GLShader> {
		var shader = gl.createShader(type);
		gl.shaderSource(shader, source);
		gl.compileShader(shader);

		if (gl.getShaderParameter(shader, GL.COMPILE_STATUS) == 0) {
			var message = gl.getShaderInfoLog(shader);
			gl.deleteShader(shader);
			Log.warn(message);
			return null;
		}

		return shader;
	}

	static function createProgram(gl:GLRenderContext, vertexSource:String, fragmentSource:String):Null<GLProgram> {
		var vertexShader = compileShader(gl, vertexSource, GL.VERTEX_SHADER);
		if (vertexShader == null) {
			return null;
		}

		var fragmentShader = compileShader(gl, fragmentSource, GL.FRAGMENT_SHADER);
		if (fragmentShader == null) {
			gl.deleteShader(vertexShader);
			return null;
		}

		var program = gl.createProgram();
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);
		gl.linkProgram(program);

		if (gl.getProgramParameter(program, GL.LINK_STATUS) == 0) {
			var message = gl.getProgramInfoLog(program);
			Log.warn(message);
			gl.deleteProgram(program);
			gl.deleteShader(vertexShader);
			gl.deleteShader(fragmentShader);
			return null;
		}

		return program;
	}

	static inline final fsSource = '
		precision mediump float;

		varying vec2 vTextureCoord;
		varying vec4 vColorMultiplier;
		varying vec4 vColorOffset;
		varying float vPremultipliedAlpha;

		uniform sampler2D uSampler;

		void main(void) {
			vec4 color = texture2D(uSampler, vTextureCoord);

			if (color.a == 0.0) {

				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);

			} else {
					/** mix is a linear interpolation function that interpolates between first and second
					*   parameter, controlled by the third one. The function looks like this:
					*
					*   mix (x, y, a) = x * (1.0 - a) + y * a
					*
					*  As vPremultipliedAlpha is 0.0 or 1.0 we basically switch on/off first or the second paramter
					*  respectively
					*/

					color = vec4 (color.rgb / mix (1.0, color.a, vPremultipliedAlpha), color.a);

					color = vColorOffset + (color * vColorMultiplier);

					gl_FragColor = vec4 (color.rgb * mix (1.0, color.a, vPremultipliedAlpha), color.a);

			}

		}
	';

	static inline final vsSource = '
		attribute vec2 aVertexPosition;
		attribute vec2 aTextureCoord;
		attribute vec4 aColorMultiplier;
		attribute vec4 aColorOffset;
		attribute float aPremultipliedAlpha;

		uniform mat4 uProjMatrix;
		uniform vec4 uPostionScale;

		varying vec2 vTextureCoord;
		varying vec4 vColorMultiplier;
		varying vec4 vColorOffset;
		varying float vPremultipliedAlpha;

		void main(void) {
			gl_Position = uProjMatrix * vec4(aVertexPosition, 0, 1) * uPostionScale;
			vTextureCoord = aTextureCoord;
			vColorMultiplier = aColorMultiplier;
			vColorOffset = aColorOffset;
			vPremultipliedAlpha = aPremultipliedAlpha;
		}
	';
}
