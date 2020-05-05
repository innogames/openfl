package openfl._internal.renderer;

import lime.graphics.CanvasRenderContext;

class RenderSession {
	public var allowSmoothing:Bool;
	public final clearRenderDirty:Bool;
	public var context:CanvasRenderContext;
	public var element:js.html.DivElement;
	public var forceSmoothing:Bool;
	public var roundPixels:Bool;
	public var pixelRatio:Float = 1.0;
	public var blendModeManager:AbstractBlendModeManager;
	public var maskManager:AbstractMaskManager;

	public function new(clearRenderDirty:Bool) {
		this.clearRenderDirty = clearRenderDirty;
		allowSmoothing = true;
	}
}
