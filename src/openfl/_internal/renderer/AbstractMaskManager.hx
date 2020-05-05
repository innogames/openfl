package openfl._internal.renderer;

import openfl.display.DisplayObject;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;

@:access(openfl.display.DisplayObject)
class AbstractMaskManager {
	public function pushMask(mask:DisplayObject) {}

	public function pushObject(object:DisplayObject, handleScrollRect:Bool = true) {}

	public function pushRect(rect:Rectangle, transform:Matrix) {}

	public function popMask() {}

	public function popObject(object:DisplayObject, handleScrollRect:Bool = true) {}

	public function popRect() {}
}
