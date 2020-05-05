package openfl._internal.renderer;

class RenderSession {
	public var allowSmoothing:Bool;
	public final clearRenderDirty:Bool;
	public var forceSmoothing:Bool;
	public var roundPixels:Bool;
	public var pixelRatio:Float = 1.0;

	function new(clearRenderDirty:Bool) {
		this.clearRenderDirty = clearRenderDirty;
		allowSmoothing = true;
	}
}
