package openfl._internal.renderer.canvas;

import openfl.display.*;
import openfl.geom.*;

@:access(openfl.display.DisplayObject)
class CanvasMaskManager {
	final renderSession:CanvasRenderSession;
	public function new(renderSession:CanvasRenderSession) {
		this.renderSession = renderSession;
	}

	function pushMask(mask:DisplayObject) {
		var context = renderSession.context;

		context.save();

		// var cacheAlpha = mask.__worldAlpha;
		var transform = mask.__renderTransform;
		var pixelRatio = renderSession.pixelRatio;
		context.setTransform(transform.a * pixelRatio, transform.b, transform.c, transform.d * pixelRatio, transform.tx * pixelRatio,
			transform.ty * pixelRatio);

		context.beginPath();
		mask.__renderCanvasMask(renderSession);

		context.clip();

		// mask.worldAlpha = cacheAlpha;
	}

	public function pushObject(object:DisplayObject, handleScrollRect:Bool = true) {
		if (handleScrollRect && object.__scrollRect != null) {
			pushRect(object.__scrollRect, object.__renderTransform);
		}

		if (!object.__cacheBitmapRender && object.__mask != null) {
			pushMask(object.__mask);
		}
	}

	public function pushRect(rect:Rectangle, transform:Matrix) {
		var context = renderSession.context;
		context.save();

		var pixelRatio = renderSession.pixelRatio;
		context.setTransform(transform.a * pixelRatio, transform.b, transform.c, transform.d * pixelRatio, transform.tx * pixelRatio,
			transform.ty * pixelRatio);

		context.beginPath();
		context.rect(rect.x, rect.y, rect.width, rect.height);
		context.clip();
	}

	function popMask() {
		renderSession.context.restore();
	}

	public function popObject(object:DisplayObject, handleScrollRect:Bool = true) {
		if (!object.__cacheBitmapRender && object.__mask != null) {
			popMask();
		}

		if (handleScrollRect && object.__scrollRect != null) {
			popRect();
		}
	}

	public function popRect() {
		renderSession.context.restore();
	}
}
