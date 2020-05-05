package openfl.display;

import openfl._internal.renderer.canvas.CanvasRenderSession;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

interface IBitmapDrawable {
	private var __transform:Matrix;

	private function __getBounds(rect:Rectangle, matrix:Matrix):Void;
	private function __renderToBitmap(renderSession:CanvasRenderSession, matrix:Matrix, blendMode:BlendMode):Void;
}
