package lime.math;

import openfl.geom.Point as Vector2;

class Rectangle {
	public var bottom(get, set):Float;
	public var bottomRight(get, set):Vector2;
	public var height:Float;
	public var left(get, set):Float;
	public var right(get, set):Float;
	public var size(get, set):Vector2;
	public var top(get, set):Float;
	public var topLeft(get, set):Vector2;
	public var width:Float;
	public var x:Float;
	public var y:Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):Void {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function clone():Rectangle {
		return new Rectangle(x, y, width, height);
	}

	public function contains(x:Float, y:Float):Bool {
		return x >= this.x && y >= this.y && x < right && y < bottom;
	}

	public function containsPoint(point:Vector2):Bool {
		return contains(point.x, point.y);
	}

	public function containsRect(rect:Rectangle):Bool {
		if (rect.width <= 0 || rect.height <= 0) {
			return rect.x > x && rect.y > y && rect.right < right && rect.bottom < bottom;
		} else {
			return rect.x >= x && rect.y >= y && rect.right <= right && rect.bottom <= bottom;
		}
	}

	public function copyFrom(sourceRect:Rectangle):Void {
		x = sourceRect.x;
		y = sourceRect.y;
		width = sourceRect.width;
		height = sourceRect.height;
	}

	public function equals(toCompare:Rectangle):Bool {
		return toCompare != null && x == toCompare.x && y == toCompare.y && width == toCompare.width && height == toCompare.height;
	}

	public function inflate(dx:Float, dy:Float):Void {
		x -= dx;
		width += dx * 2;
		y -= dy;
		height += dy * 2;
	}

	public function inflatePoint(point:Vector2):Void {
		inflate(point.x, point.y);
	}

	public function intersection(toIntersect:Rectangle):Rectangle {
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;

		if (x1 <= x0) {
			return new Rectangle();
		}

		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;

		if (y1 <= y0) {
			return new Rectangle();
		}

		return new Rectangle(x0, y0, x1 - x0, y1 - y0);
	}

	public function intersects(toIntersect:Rectangle):Bool {
		var x0 = x < toIntersect.x ? toIntersect.x : x;
		var x1 = right > toIntersect.right ? toIntersect.right : right;

		if (x1 <= x0) {
			return false;
		}

		var y0 = y < toIntersect.y ? toIntersect.y : y;
		var y1 = bottom > toIntersect.bottom ? toIntersect.bottom : bottom;

		return y1 > y0;
	}

	public function isEmpty():Bool {
		return (width <= 0 || height <= 0);
	}

	public function offset(dx:Float, dy:Float):Void {
		x += dx;
		y += dy;
	}

	public function offsetPoint(point:Vector2):Void {
		x += point.x;
		y += point.y;
	}

	public function setEmpty():Void {
		x = y = width = height = 0;
	}

	public function setTo(xa:Float, ya:Float, widtha:Float, heighta:Float):Void {
		x = xa;
		y = ya;
		width = widtha;
		height = heighta;
	}

	public function union(toUnion:Rectangle):Rectangle {
		if (width == 0 || height == 0) {
			return toUnion.clone();
		} else if (toUnion.width == 0 || toUnion.height == 0) {
			return clone();
		}

		var x0 = x > toUnion.x ? toUnion.x : x;
		var x1 = right < toUnion.right ? toUnion.right : right;
		var y0 = y > toUnion.y ? toUnion.y : y;
		var y1 = bottom < toUnion.bottom ? toUnion.bottom : bottom;

		return new Rectangle(x0, y0, x1 - x0, y1 - y0);
	}

	public function __contract(x:Float, y:Float, width:Float, height:Float):Void {
		if (this.width == 0 && this.height == 0) {
			return;
		}

		// var cacheRight = right;
		// var cacheBottom = bottom;

		if (this.x < x)
			this.x = x;
		if (this.y < y)
			this.y = y;
		if (this.right > x + width)
			this.width = x + width - this.x;
		if (this.bottom > y + height)
			this.height = y + height - this.y;
	}

	public function __expand(x:Float, y:Float, width:Float, height:Float):Void {
		if (this.width == 0 && this.height == 0) {
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			return;
		}

		var cacheRight = right;
		var cacheBottom = bottom;

		if (this.x > x)
			this.x = x;
		if (this.y > y)
			this.y = y;
		if (cacheRight < x + width)
			this.width = x + width - this.x;
		if (cacheBottom < y + height)
			this.height = y + height - this.y;
	}

	// Getters & Setters

	private function get_bottom():Float {
		return y + height;
	}

	private function set_bottom(b:Float):Float {
		height = b - y;
		return b;
	}

	private function get_bottomRight():Vector2 {
		return new Vector2(x + width, y + height);
	}

	private function set_bottomRight(p:Vector2):Vector2 {
		width = p.x - x;
		height = p.y - y;
		return p.clone();
	}

	private function get_left():Float {
		return x;
	}

	private function set_left(l:Float):Float {
		width -= l - x;
		x = l;
		return l;
	}

	private function get_right():Float {
		return x + width;
	}

	private function set_right(r:Float):Float {
		width = r - x;
		return r;
	}

	private function get_size():Vector2 {
		return new Vector2(width, height);
	}

	private function set_size(p:Vector2):Vector2 {
		width = p.x;
		height = p.y;
		return p.clone();
	}

	private function get_top():Float {
		return y;
	}

	private function set_top(t:Float):Float {
		height -= t - y;
		y = t;
		return t;
	}

	private function get_topLeft():Vector2 {
		return new Vector2(x, y);
	}

	private function set_topLeft(p:Vector2):Vector2 {
		x = p.x;
		y = p.y;
		return p.clone();
	}
}
