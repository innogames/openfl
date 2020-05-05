package openfl._internal.renderer.canvas;

import lime.graphics.CanvasRenderContext;

class CanvasRenderSession extends RenderSession {
	public final context:CanvasRenderContext;
	public final blendModeManager:CanvasBlendModeManager;
	public final maskManager:CanvasMaskManager;

	public function new(context:CanvasRenderContext, clearRenderDirty:Bool) {
		super(clearRenderDirty);
		this.context = context;
		maskManager = new CanvasMaskManager(this);
		blendModeManager = new CanvasBlendModeManager(this);
	}
}
