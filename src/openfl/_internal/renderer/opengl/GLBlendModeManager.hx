package openfl._internal.renderer.opengl;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import openfl._internal.renderer.AbstractBlendModeManager;
import openfl.display.BlendMode;

class GLBlendModeManager extends AbstractBlendModeManager {
	private var currentBlendMode:BlendMode;
	private var gl:GLRenderContext;

	public function new(gl:GLRenderContext) {
		this.gl = gl;

		setBlendMode(NORMAL);
		gl.enable(GL.BLEND);
	}

	public override function setBlendMode(blendMode:BlendMode):Void {
		if (currentBlendMode == blendMode)
			return;

		currentBlendMode = blendMode;

		switch (blendMode) {
			case ADD:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFunc(GL.ONE, GL.ONE);

			case MULTIPLY:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFunc(GL.DST_COLOR, GL.ONE_MINUS_SRC_ALPHA);

			case SCREEN:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_COLOR);

			case SUBTRACT:
				gl.blendEquation(GL.FUNC_REVERSE_SUBTRACT);
				gl.blendFunc(GL.ONE, GL.ONE);

			#if desktop
			case DARKEN:
				gl.blendEquation(0x8007); // GL_MIN
				gl.blendFunc(GL.ONE, GL.ONE);

			case LIGHTEN:
				gl.blendEquation(0x8008); // GL_MAX
				gl.blendFunc(GL.ONE, GL.ONE);
			#end

			default:
				gl.blendEquation(GL.FUNC_ADD);
				gl.blendFunc(GL.ONE, GL.ONE_MINUS_SRC_ALPHA);
		}
	}
}
