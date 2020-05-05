package openfl._internal.renderer.canvas;

import openfl.display.BlendMode;

class CanvasBlendModeManager {
	final renderSession:CanvasRenderSession;
	var currentBlendMode:BlendMode;

	public function new(renderSession:CanvasRenderSession) {
		this.renderSession = renderSession;
	}

	public function setBlendMode(blendMode:BlendMode) {
		if (currentBlendMode == blendMode)
			return;

		currentBlendMode = blendMode;

		switch (blendMode) {
			case ADD:
				renderSession.context.globalCompositeOperation = "lighter";

			case ALPHA:
				renderSession.context.globalCompositeOperation = "destination-in";

			case DARKEN:
				renderSession.context.globalCompositeOperation = "darken";

			case DIFFERENCE:
				renderSession.context.globalCompositeOperation = "difference";

			case ERASE:
				renderSession.context.globalCompositeOperation = "destination-out";

			case HARDLIGHT:
				renderSession.context.globalCompositeOperation = "hard-light";

			// case INVERT:

			// renderSession.context.globalCompositeOperation = "";

			case LAYER:
				renderSession.context.globalCompositeOperation = "source-over";

			case LIGHTEN:
				renderSession.context.globalCompositeOperation = "lighten";

			case MULTIPLY:
				renderSession.context.globalCompositeOperation = "multiply";

			case OVERLAY:
				renderSession.context.globalCompositeOperation = "overlay";

			case SCREEN:
				renderSession.context.globalCompositeOperation = "screen";

			// case SHADER:

			// renderSession.context.globalCompositeOperation = "";

			// case SUBTRACT:

			// renderSession.context.globalCompositeOperation = "";

			default:
				renderSession.context.globalCompositeOperation = "source-over";
		}
	}
}
