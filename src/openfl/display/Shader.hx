package openfl.display;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;
import openfl._internal.stage3D.GLUtils;
import openfl.display.ShaderParameter;

class Shader {
	public var data(get, never):ShaderData;
	public var glProgram(default, null):GLProgram;
	public var precisionHint:ShaderPrecision;

	var gl:GLRenderContext;

	final __data:ShaderData;
	final __glFragmentSource:String;
	final __glVertexSource:String;
	var __inputBitmapData:Array<ShaderParameterSampler>;
	var __param:Array<ShaderParameter>;
	var __skipEnableVertexAttribArray:Bool;

	function __getGlFragmentSource() return "varying float vAlpha;
		varying vec4 vColorMultipliers0;
		varying vec4 vColorMultipliers1;
		varying vec4 vColorMultipliers2;
		varying vec4 vColorMultipliers3;
		varying vec4 vColorOffsets;
		varying vec2 vTexCoord;
		
		uniform bool uColorTransform;
		uniform sampler2D uImage0;
		
		void main(void) {
			
			vec4 color = texture2D (uImage0, vTexCoord);
			
			if (color.a == 0.0) {
				
				gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
				
			} else if (uColorTransform) {
				
				color = vec4 (color.rgb / color.a, color.a);
				
				mat4 colorMultiplier;
				colorMultiplier[0] = vColorMultipliers0;
				colorMultiplier[1] = vColorMultipliers1;
				colorMultiplier[2] = vColorMultipliers2;
				colorMultiplier[3] = vColorMultipliers3;
				
				color = vColorOffsets + (color * colorMultiplier);
				
				if (color.a > 0.0) {
					
					gl_FragColor = vec4 (color.rgb * color.a * vAlpha, color.a * vAlpha);
					
				} else {
					
					gl_FragColor = vec4 (0.0, 0.0, 0.0, 0.0);
					
				}
				
			} else {
				
				gl_FragColor = color * vAlpha;
				
			}
		}";
	function __getGlVertexSource() return "attribute float aAlpha;
		attribute vec4 aColorMultipliers0;
		attribute vec4 aColorMultipliers1;
		attribute vec4 aColorMultipliers2;
		attribute vec4 aColorMultipliers3;
		attribute vec4 aColorOffsets;
		attribute vec4 aPosition;
		attribute vec2 aTexCoord;
		varying float vAlpha;
		varying vec4 vColorMultipliers0;
		varying vec4 vColorMultipliers1;
		varying vec4 vColorMultipliers2;
		varying vec4 vColorMultipliers3;
		varying vec4 vColorOffsets;
		varying vec2 vTexCoord;
		
		uniform mat4 uMatrix;
		uniform bool uColorTransform;
		
		void main(void) {
			
			vAlpha = aAlpha;
			vTexCoord = aTexCoord;
			
			if (uColorTransform) {
				
				vColorMultipliers0 = aColorMultipliers0;
				vColorMultipliers1 = aColorMultipliers1;
				vColorMultipliers2 = aColorMultipliers2;
				vColorMultipliers3 = aColorMultipliers3;
				vColorOffsets = aColorOffsets;
				
			}
			
			gl_Position = uMatrix * aPosition;
		}";

	public function new() {
		precisionHint = FULL;
		__data = new ShaderData();
		__glVertexSource = __getGlVertexSource();
		__glFragmentSource = __getGlFragmentSource();
		__skipEnableVertexAttribArray = false;
	}

	function __disable() {
		if (glProgram != null) {
			__disableGL();
		}
	}

	function __disableGL() {
		if (__data.uImage0 != null) {
			__data.uImage0.input = null;
		}

		for (parameter in __param) {
			parameter.disable(gl);
		}

		gl.bindBuffer(GL.ARRAY_BUFFER, null);
		gl.bindTexture(GL.TEXTURE_2D, null);
	}

	function __enable() {
		__init();

		if (glProgram != null) {
			__enableGL();
		}
	}

	function __enableGL() {
		for (input in __inputBitmapData) {
			input.enable(gl);
		}
	}

	function __init() {
		if (glProgram == null) {
			__initGL();
		}
	}

	function __initGL() {
		if (__param == null) {
			glProgram = null;

			__inputBitmapData = new Array();
			__param = new Array();

			__processGLData(__glVertexSource, "attribute");
			__processGLData(__glVertexSource, "uniform");
			__processGLData(__glFragmentSource, "uniform");
		}

		if (gl != null && glProgram == null) {
			var fragment = "#ifdef GL_ES
				precision "

				+ (precisionHint == FULL ? "mediump" : "lowp")
				+ " float;
				#endif
				"
				+ __glFragmentSource;

			glProgram = GLUtils.createProgram(gl, __glVertexSource, fragment);

			if (glProgram != null) {
				for (input in __inputBitmapData) {
					input.init(gl, glProgram);
				}

				for (parameter in __param) {
					parameter.init(gl, glProgram);
				}
			}
		}
	}

	function __processGLData(source:String, storageType:String) {
		var lastMatch = 0, position, regex, name, type;

		var isUniform = storageType == "uniform";
		if (isUniform) {
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;
		} else {
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9]+)/;
		}

		var textureIndex = 0;
		while (regex.matchSub(source, lastMatch)) {
			type = regex.matched(1);
			name = regex.matched(2);

			if (StringTools.startsWith(type, "sampler")) {
				var input = new ShaderParameterSampler(name, textureIndex);
				textureIndex++;
				__inputBitmapData.push(input);
				Reflect.setField(__data, name, input);
			} else {
				var parameter:ShaderParameter;
				if (!isUniform) {
					parameter = new ShaderParameterAttrib(name);
				} else {
					parameter = switch (type) {
						case "bool": new ShaderParameterBool(name);
						case "double", "float": new ShaderParameterFloat(name);
						case "int", "uint": new ShaderParameterInt(name);
						case "bvec2": new ShaderParameterBool2(name);
						case "bvec3": new ShaderParameterBool3(name);
						case "bvec4": new ShaderParameterBool4(name);
						case "ivec2", "uvec2": new ShaderParameterInt2(name);
						case "ivec3", "uvec3": new ShaderParameterInt3(name);
						case "ivec4", "uvec4": new ShaderParameterInt4(name);
						case "vec2", "dvec2": new ShaderParameterFloat2(name);
						case "vec3", "dvec3": new ShaderParameterFloat3(name);
						case "vec4", "dvec4": new ShaderParameterFloat4(name);
						case "mat2", "mat2x2": new ShaderParameterMatrix2(name);
						case "mat3", "mat3x3": new ShaderParameterMatrix3(name);
						case "mat4", "mat4x4": new ShaderParameterMatrix4(name);
						default: throw "unsupported shader parameter type: " + type;
					}
				}
				__param.push(parameter);
				Reflect.setField(__data, name, parameter);
			}

			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}

	function __update() {
		if (glProgram != null) {
			__updateGL();
		}
	}

	function __updateGL() {
		for (input in __inputBitmapData) {
			input.update(gl, false);
		}

		for (parameter in __param) {
			parameter.update(gl, __skipEnableVertexAttribArray);
		}
	}

	function get_data():ShaderData {
		__init();
		return __data;
	}
}
