package openfl._internal.renderer.opengl;

import lime.graphics.GLRenderContext;
import openfl.display.Shader;

@:access(openfl.display.Shader)
class GLShaderManager {
	public var currentShader(default, null):Shader;
	public var defaultShader:Shader;

	private var gl:GLRenderContext;

	public function new(gl:GLRenderContext) {
		this.gl = gl;

		defaultShader = new Shader();
		initShader(defaultShader);
	}

	public function initShader(shader:Shader):Shader {
		if (shader != null) {
			// TODO: Change of GL context?

			if (shader.gl == null) {
				shader.gl = gl;
				shader.__init();
			}

			// currentShader = shader;
			return shader;
		}

		return defaultShader;
	}

	public function setShader(shader:Shader):Void {
		if (currentShader == shader)
			return;

		if (currentShader != null) {
			currentShader.__disable();
		}

		if (shader == null) {
			currentShader = null;
			gl.useProgram(null);
			return;
		} else {
			currentShader = shader;
			initShader(shader);
			gl.useProgram(shader.glProgram);
			currentShader.__enable();
		}
	}

	public function updateShader(shader:Shader):Void {
		if (currentShader != null) {
			currentShader.__update();
		}
	}
}
