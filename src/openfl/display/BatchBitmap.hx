package openfl.display;

import openfl._internal.renderer.RenderSession;

class BatchBitmap extends Bitmap {
	#if !display
	override function __renderGL(renderSession:RenderSession) {
		renderSession.painter.batchQuad(
			width, height, __renderTransform,
			shader, __bitmapData,
			0, 0,
			1, 0,
			0, 1,
			1, 1,
			__worldAlpha,
			__worldColorTransform
		);
	}
	#end
}