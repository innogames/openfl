package openfl.display;

import lime.ui.MouseCursor;
import openfl.geom.Rectangle;

@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.geom.Point)
class Sprite extends DisplayObjectContainer {
	public var buttonMode:Bool;
	public var dropTarget(default, null):DisplayObject;
	public var graphics(get, never):Graphics;
	public var hitArea:Sprite;
	public var useHandCursor:Bool;

	public function new() {
		super();

		buttonMode = false;
		useHandCursor = true;
	}

	public function startDrag(lockCenter:Bool = false, bounds:Rectangle = null):Void {
		if (stage != null) {
			stage.__startDrag(this, lockCenter, bounds);
		}
	}

	public function stopDrag():Void {
		if (stage != null) {
			stage.__stopDrag(this);
		}
	}

	private override function __getCursor():MouseCursor {
		return (buttonMode && useHandCursor) ? POINTER : null;
	}

	private override function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject,
			hitTestWhenMouseDisabled:Bool = false):Bool {
		if (!hitObject.visible || __isMask)
			return false;

		if (interactiveOnly && !mouseEnabled && !mouseChildren) {
			if (__hitTestHitArea(x, y, shapeFlag, stack, interactiveOnly, hitObject, hitTestWhenMouseDisabled)) {
				return true;
			} else if (!hitTestWhenMouseDisabled) {
				return false;
			}
		}

		if (mask != null && !mask.__hitTestMask(x, y))
			return __hitTestHitArea(x, y, shapeFlag, stack, interactiveOnly, hitObject, hitTestWhenMouseDisabled);

		if (!__isPointInScrollRect(x, y)) {
			return __hitTestHitArea(x, y, shapeFlag, stack, true, hitObject, hitTestWhenMouseDisabled);
		}

		if (super.__hitTest(x, y, shapeFlag, stack, interactiveOnly, hitObject, hitTestWhenMouseDisabled)) {
			return interactiveOnly;
		} else if (hitArea == null && __graphics != null && __graphics.__hitTest(x, y, shapeFlag, __getRenderTransform())) {
			if (stack != null && !hitTestWhenMouseDisabled && (!interactiveOnly || mouseEnabled)) {
				stack.push(hitObject);
			}

			return true;
		}

		return __hitTestHitArea(x, y, shapeFlag, stack, interactiveOnly, hitObject, hitTestWhenMouseDisabled);
	}

	private function __hitTestHitArea(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject,
			hitTestWhenMouseDisabled:Bool = false):Bool {
		if (hitArea != null) {
			if (!hitArea.mouseEnabled) {
				hitArea.mouseEnabled = true;
				var hitTest = hitArea.__hitTest(x, y, shapeFlag, null, true, hitObject, hitTestWhenMouseDisabled);
				hitArea.mouseEnabled = false;

				if (stack != null && hitTest && !hitTestWhenMouseDisabled) {
					stack[stack.length] = hitObject;
				}

				return hitTest;
			}
		}

		return false;
	}

	private override function __hitTestMask(x:Float, y:Float):Bool {
		if (super.__hitTestMask(x, y)) {
			return true;
		} else if (__graphics != null && __graphics.__hitTest(x, y, true, __getRenderTransform())) {
			return true;
		}

		return false;
	}

	// Get & Set Methods

	private function get_graphics():Graphics {
		if (__graphics == null) {
			__graphics = new Graphics(this);
		}

		return __graphics;
	}

	private override function get_tabEnabled():Bool {
		return (__tabEnabled == null ? buttonMode : __tabEnabled);
	}
}
