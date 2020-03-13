package openfl;

import haxe.Constraints.Function;

@:multiType(T)
abstract Vector<T>(IVector<T>) from IVector<T> {
	public var fixed(get, set):Bool;
	public var length(get, set):Int;

	public function new(?length:Int, ?fixed:Bool):Void;

	public inline function concat(?a:Vector<T>):Vector<T> {
		return this.concat(cast a);
	}

	public inline function filter(callback:T->Bool):Vector<T> {
		return this.filter(callback);
	}

	public inline function copy():Vector<T> {
		return this.copy();
	}

	@:arrayAccess inline function get(index:Int):T {
		return this.get(index);
	}

	public inline function indexOf(x:T, ?from:Int = 0):Int {
		return this.indexOf(x, from);
	}

	public inline function insertAt(index:Int, element:T):Void {
		this.insertAt(index, element);
	}

	public inline function iterator():Iterator<T> {
		return this.iterator();
	}

	public inline function join(sep:String = ","):String {
		return this.join(sep);
	}

	public inline function lastIndexOf(x:T, ?from:Int = 0):Int {
		return this.lastIndexOf(x, from);
	}

	public inline function pop():Null<T> {
		return this.pop();
	}

	public inline function push(x:T):Int {
		return this.push(x);
	}

	public inline function removeAt(index:Int):T {
		return this.removeAt(index);
	}

	public inline function reverse():Vector<T> {
		return this.reverse();
	}

	@:arrayAccess inline function set(index:Int, value:T):T {
		return this.set(index, value);
	}

	public inline function shift():Null<T> {
		return this.shift();
	}

	public inline function slice(?pos:Int, ?end:Int):Vector<T> {
		return this.slice(pos, end);
	}

	public inline function sort(f:T->T->Int):Void {
		this.sort(f);
	}

	public inline function splice(pos:Int, len:Int):Vector<T> {
		return this.splice(pos, len);
	}

	public inline function toString():String {
		return this.toString();
	}

	public inline function unshift(x:T):Void {
		this.unshift(x);
	}

	public inline static function ofArray<T>(a:Array<T>):Vector<T> {
		var vector = new Vector<T>();
		for (i in 0...a.length) {
			vector[i] = a[i];
		}
		return vector;
	}

	public inline static function isVector(obj:Any):Bool {
		return Std.is(obj, IVector);
	}

	public inline static function convert<T, U>(v:Vector<T>):Vector<U> {
		return cast v;
	}

	@:to static function toBoolVector<T:Bool>(t:IVector<T>, length:Int, fixed:Bool):IVector<T> {
		return cast new BoolVector(length, fixed);
	}

	@:to static function toIntVector<T:Int>(t:IVector<T>, length:Int, fixed:Bool):IVector<T> {
		return cast new IntVector(length, fixed);
	}

	@:to static function toFloatVector<T:Float>(t:IVector<T>, length:Int, fixed:Bool):IVector<T> {
		return cast new FloatVector(length, fixed);
	}

	@:to static function toFunctionVector<T:Function>(t:IVector<T>, length:Int, fixed:Bool):IVector<T> {
		return cast new FunctionVector(length, fixed);
	}

	@:to static function toObjectVector<T>(t:IVector<T>, length:Int, fixed:Bool):IVector<T> {
		return new ObjectVector<T>(length, fixed);
	}

	inline function get_fixed():Bool {
		return this.fixed;
	}

	inline function set_fixed(value:Bool):Bool {
		return this.fixed = value;
	}

	inline function get_length():Int {
		return this.length;
	}

	inline function set_length(value:Int):Int {
		return this.length = value;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class BoolVector implements IVector<Bool> {
	public var fixed:Bool;
	public var length(get, set):Int;

	private var __array:Array<Bool>;

	public function new(?length:Int, ?fixed:Bool, ?array:Array<Bool>) {
		if (array == null) {
			array = new Array<Bool>();
		}

		__array = array;

		if (length != null) {
			this.length = length;
		}

		this.fixed = (fixed == true);
	}

	public function concat(?a:IVector<Bool>):IVector<Bool> {
		if (a == null) {
			return new BoolVector(__array.copy());
		} else {
			return new BoolVector(__array.concat(cast(a, BoolVector).__array));
		}
	}

	public function filter(callback:Bool->Bool):IVector<Bool> {
		return new BoolVector(fixed, __array.filter(callback));
	}

	public function copy():IVector<Bool> {
		return new BoolVector(fixed, __array.copy());
	}

	public function get(index:Int):Bool {
		if (index >= __array.length) {
			return false;
		} else {
			return __array[index];
		}
	}

	public function indexOf(x:Bool, ?from:Int = 0):Int {
		for (i in from...__array.length) {
			if (__array[i] == x) {
				return i;
			}
		}

		return -1;
	}

	public function insertAt(index:Int, element:Bool):Void {
		if (!fixed || index < __array.length) {
			__array.insert(index, element);
		}
	}

	public function iterator():Iterator<Bool> {
		return __array.iterator();
	}

	public function join(sep:String = ","):String {
		return __array.join(sep);
	}

	public function lastIndexOf(x:Bool, ?from:Int = 0):Int {
		var i = __array.length - 1;

		while (i >= from) {
			if (__array[i] == x)
				return i;
			i--;
		}

		return -1;
	}

	public function pop():Null<Bool> {
		if (!fixed) {
			return __array.pop();
		} else {
			return null;
		}
	}

	public function push(x:Bool):Int {
		if (!fixed) {
			return __array.push(x);
		} else {
			return __array.length;
		}
	}

	public function removeAt(index:Int):Bool {
		if (!fixed || index < __array.length) {
			return __array.splice(index, 1)[0];
		}

		return false;
	}

	public function reverse():IVector<Bool> {
		__array.reverse();
		return this;
	}

	public function set(index:Int, value:Bool):Bool {
		if (!fixed || index < __array.length) {
			return __array[index] = value;
		} else {
			return value;
		}
	}

	public function shift():Null<Bool> {
		if (!fixed) {
			return __array.shift();
		} else {
			return null;
		}
	}

	public function slice(?startIndex:Int = 0, ?endIndex:Int = 16777215):IVector<Bool> {
		return new BoolVector(__array.slice(startIndex, endIndex));
	}

	public function sort(f:Bool->Bool->Int):Void {
		__array.sort(f);
	}

	public function splice(pos:Int, len:Int):IVector<Bool> {
		return new BoolVector(__array.splice(pos, len));
	}

	@:noCompletion @:keep private function toJSON() {
		return __array;
	}

	public function toString():String {
		return __array != null ? __array.toString() : null;
	}

	public function unshift(x:Bool):Void {
		if (!fixed) {
			__array.unshift(x);
		}
	}

	// Getters & Setters

	@:noCompletion private function get_length():Int {
		return __array.length;
	}

	@:noCompletion private function set_length(value:Int):Int {
		if (!fixed) {
			#if cpp
			cpp.NativeArray.setSize(__array, value);
			#else
			var currentLength = __array.length;
			if (value < 0)
				value = 0;

			if (value > currentLength) {
				for (i in currentLength...value) {
					__array[i] = false;
				}
			} else {
				while (__array.length > value) {
					__array.pop();
				}
			}
			#end
		}

		return __array.length;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class FloatVector implements IVector<Float> {
	public var fixed:Bool;
	public var length(get, set):Int;

	private var __array:Array<Float>;

	public function new(?length:Int, ?fixed:Bool, ?array:Array<Float>) {
		if (array == null) {
			array = new Array<Float>();
		}

		__array = array;

		if (length != null) {
			this.length = length;
		}

		this.fixed = (fixed == true);
	}

	public function concat(?a:IVector<Float>):IVector<Float> {
		if (a == null) {
			return new FloatVector(__array.copy());
		} else {
			return new FloatVector(__array.concat(cast(a, FloatVector).__array));
		}
	}

	public function filter(callback:Float->Bool):IVector<Float> {
		return new FloatVector(fixed, __array.filter(callback));
	}

	public function copy():IVector<Float> {
		return new FloatVector(fixed, __array.copy());
	}

	public function get(index:Int):Float {
		return __array[index];
	}

	public function indexOf(x:Float, ?from:Int = 0):Int {
		for (i in from...__array.length) {
			if (__array[i] == x) {
				return i;
			}
		}

		return -1;
	}

	public function insertAt(index:Int, element:Float):Void {
		if (!fixed || index < __array.length) {
			__array.insert(index, element);
		}
	}

	public function iterator():Iterator<Float> {
		return __array.iterator();
	}

	public function join(sep:String = ","):String {
		return __array.join(sep);
	}

	public function lastIndexOf(x:Float, ?from:Int = 0):Int {
		var i = __array.length - 1;

		while (i >= from) {
			if (__array[i] == x)
				return i;
			i--;
		}

		return -1;
	}

	public function pop():Null<Float> {
		if (!fixed) {
			return __array.pop();
		} else {
			return null;
		}
	}

	public function push(x:Float):Int {
		if (!fixed) {
			return __array.push(x);
		} else {
			return __array.length;
		}
	}

	public function removeAt(index:Int):Float {
		if (!fixed || index < __array.length) {
			return __array.splice(index, 1)[0];
		}

		return 0;
	}

	public function reverse():IVector<Float> {
		__array.reverse();
		return this;
	}

	public function set(index:Int, value:Float):Float {
		if (!fixed || index < __array.length) {
			return __array[index] = value;
		} else {
			return value;
		}
	}

	public function shift():Null<Float> {
		if (!fixed) {
			return __array.shift();
		} else {
			return null;
		}
	}

	public function slice(?startIndex:Int = 0, ?endIndex:Int = 16777215):IVector<Float> {
		return new FloatVector(__array.slice(startIndex, endIndex));
	}

	public function sort(f:Float->Float->Int):Void {
		__array.sort(f);
	}

	public function splice(pos:Int, len:Int):IVector<Float> {
		return new FloatVector(__array.splice(pos, len));
	}

	@:noCompletion @:keep private function toJSON() {
		return __array;
	}

	public function toString():String {
		return __array != null ? __array.toString() : null;
	}

	public function unshift(x:Float):Void {
		if (!fixed) {
			__array.unshift(x);
		}
	}

	// Getters & Setters

	@:noCompletion private function get_length():Int {
		return __array.length;
	}

	@:noCompletion private function set_length(value:Int):Int {
		if (!fixed) {
			#if cpp
			cpp.NativeArray.setSize(__array, value);
			#else
			var currentLength = __array.length;
			if (value < 0)
				value = 0;

			if (value > currentLength) {
				for (i in currentLength...value) {
					__array[i] = 0;
				}
			} else {
				while (__array.length > value) {
					__array.pop();
				}
			}
			#end
		}

		return __array.length;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class FunctionVector implements IVector<Function> {
	public var fixed:Bool;
	public var length(get, set):Int;

	private var __array:Array<Function>;

	public function new(?length:Int, ?fixed:Bool, ?array:Array<Function>) {
		if (array == null) {
			array = new Array<Function>();
		}

		__array = array;

		if (length != null) {
			this.length = length;
		}

		this.fixed = (fixed == true);
	}

	public function concat(?a:IVector<Function>):IVector<Function> {
		if (a == null) {
			return new FunctionVector(__array.copy());
		} else {
			return new FunctionVector(__array.concat(cast(a, FunctionVector).__array));
		}
	}

	public function filter(callback:Function->Bool):IVector<Function> {
		return new FunctionVector(fixed, __array.filter(callback));
	}

	public function copy():IVector<Function> {
		return new FunctionVector(fixed, __array.copy());
	}

	public function get(index:Int):Function {
		if (index >= __array.length) {
			return null;
		} else {
			return __array[index];
		}
	}

	public function indexOf(x:Function, ?from:Int = 0):Int {
		for (i in from...__array.length) {
			if (Reflect.compareMethods(__array[i], x)) {
				return i;
			}
		}

		return -1;
	}

	public function insertAt(index:Int, element:Function):Void {
		if (!fixed || index < __array.length) {
			__array.insert(index, element);
		}
	}

	public function iterator():Iterator<Function> {
		return __array.iterator();
	}

	public function join(sep:String = ","):String {
		return __array.join(sep);
	}

	public function lastIndexOf(x:Function, ?from:Int = 0):Int {
		var i = __array.length - 1;

		while (i >= from) {
			if (Reflect.compareMethods(__array[i], x))
				return i;
			i--;
		}

		return -1;
	}

	public function pop():Function {
		if (!fixed) {
			return __array.pop();
		} else {
			return null;
		}
	}

	public function push(x:Function):Int {
		if (!fixed) {
			return __array.push(x);
		} else {
			return __array.length;
		}
	}

	public function removeAt(index:Int):Function {
		if (!fixed || index < __array.length) {
			return __array.splice(index, 1)[0];
		}

		return null;
	}

	public function reverse():IVector<Function> {
		__array.reverse();
		return this;
	}

	public function set(index:Int, value:Function):Function {
		if (!fixed || index < __array.length) {
			return __array[index] = value;
		} else {
			return value;
		}
	}

	public function shift():Function {
		if (!fixed) {
			return __array.shift();
		} else {
			return null;
		}
	}

	public function slice(?startIndex:Int = 0, ?endIndex:Int = 16777215):IVector<Function> {
		return new FunctionVector(__array.slice(startIndex, endIndex));
	}

	public function sort(f:Function->Function->Int):Void {
		__array.sort(f);
	}

	public function splice(pos:Int, len:Int):IVector<Function> {
		return new FunctionVector(__array.splice(pos, len));
	}

	@:noCompletion @:keep private function toJSON() {
		return __array;
	}

	public function toString():String {
		return __array != null ? __array.toString() : null;
	}

	public function unshift(x:Function):Void {
		if (!fixed) {
			__array.unshift(x);
		}
	}

	// Getters & Setters

	@:noCompletion private function get_length():Int {
		return __array.length;
	}

	@:noCompletion private function set_length(value:Int):Int {
		if (!fixed) {
			#if cpp
			cpp.NativeArray.setSize(__array, value);
			#else
			var currentLength = __array.length;
			if (value < 0)
				value = 0;

			if (value > currentLength) {
				for (i in currentLength...value) {
					__array[i] = null;
				}
			} else {
				while (__array.length > value) {
					__array.pop();
				}
			}
			#end
		}

		return __array.length;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class IntVector implements IVector<Int> {
	public var fixed:Bool;
	public var length(get, set):Int;

	private var __array:Array<Int>;

	public function new(?length:Int, ?fixed:Bool, ?array:Array<Int>) {
		if (array == null) {
			array = new Array<Int>();
		}

		__array = array;

		if (length != null) {
			this.length = length;
		}

		this.fixed = (fixed == true);
	}

	public function concat(?a:IVector<Int>):IVector<Int> {
		if (a == null) {
			return new IntVector(__array.copy());
		} else {
			return new IntVector(__array.concat(cast(a, IntVector).__array));
		}
	}

	public function filter(callback:Int->Bool):IVector<Int> {
		return new IntVector(fixed, __array.filter(callback));
	}

	public function copy():IVector<Int> {
		return new IntVector(fixed, __array.copy());
	}

	public function get(index:Int):Int {
		return __array[index];
	}

	public function indexOf(x:Int, ?from:Int = 0):Int {
		for (i in from...__array.length) {
			if (__array[i] == x) {
				return i;
			}
		}

		return -1;
	}

	public function insertAt(index:Int, element:Int):Void {
		if (!fixed || index < __array.length) {
			__array.insert(index, element);
		}
	}

	public function iterator():Iterator<Int> {
		return __array.iterator();
	}

	public function join(sep:String = ","):String {
		return __array.join(sep);
	}

	public function lastIndexOf(x:Int, ?from:Int = 0):Int {
		var i = __array.length - 1;

		while (i >= from) {
			if (__array[i] == x)
				return i;
			i--;
		}

		return -1;
	}

	public function pop():Null<Int> {
		if (!fixed) {
			return __array.pop();
		} else {
			return null;
		}
	}

	public function push(x:Int):Int {
		if (!fixed) {
			return __array.push(x);
		} else {
			return __array.length;
		}
	}

	public function removeAt(index:Int):Int {
		if (!fixed || index < __array.length) {
			return __array.splice(index, 1)[0];
		}

		return 0;
	}

	public function reverse():IVector<Int> {
		__array.reverse();
		return this;
	}

	public function set(index:Int, value:Int):Int {
		if (!fixed || index < __array.length) {
			return __array[index] = value;
		} else {
			return value;
		}
	}

	public function shift():Null<Int> {
		if (!fixed) {
			return __array.shift();
		} else {
			return null;
		}
	}

	public function slice(?startIndex:Int = 0, ?endIndex:Int = 16777215):IVector<Int> {
		return new IntVector(__array.slice(startIndex, endIndex));
	}

	public function sort(f:Int->Int->Int):Void {
		__array.sort(f);
	}

	public function splice(pos:Int, len:Int):IVector<Int> {
		return new IntVector(__array.splice(pos, len));
	}

	@:noCompletion @:keep private function toJSON() {
		return __array;
	}

	public function toString():String {
		return __array != null ? __array.toString() : null;
	}

	public function unshift(x:Int):Void {
		if (!fixed) {
			__array.unshift(x);
		}
	}

	// Getters & Setters

	@:noCompletion private function get_length():Int {
		return __array.length;
	}

	@:noCompletion private function set_length(value:Int):Int {
		if (!fixed) {
			#if cpp
			cpp.NativeArray.setSize(__array, value);
			#else
			var currentLength = __array.length;
			if (value < 0)
				value = 0;

			if (value > currentLength) {
				for (i in currentLength...value) {
					__array[i] = 0;
				}
			} else {
				while (__array.length > value) {
					__array.pop();
				}
			}
			#end
		}

		return __array.length;
	}
}

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
private class ObjectVector<T> implements IVector<T> {
	public var fixed:Bool;
	public var length(get, set):Int;

	private var __array:Array<T>;

	public function new(?length:Int, ?fixed:Bool, ?array:Array<T>) {
		if (array == null) {
			array = new Array<T>();
		}

		__array = array;

		if (length != null) {
			this.length = length;
		}

		this.fixed = (fixed == true);
	}

	public function concat(?a:IVector<T>):IVector<T> {
		if (a == null) {
			return new ObjectVector(__array.copy());
		} else {
			return new ObjectVector(__array.concat(cast(cast(a, ObjectVector<Dynamic>).__array)));
		}
	}

	public function filter(callback:T->Bool):IVector<T> {
		return new ObjectVector(fixed, __array.filter(callback));
	}

	public function copy():IVector<T> {
		return new ObjectVector(__array.copy());
	}

	public function get(index:Int):T {
		return __array[index];
	}

	public function indexOf(x:T, ?from:Int = 0):Int {
		for (i in from...__array.length) {
			if (__array[i] == x) {
				return i;
			}
		}

		return -1;
	}

	public function insertAt(index:Int, element:T):Void {
		if (!fixed || index < __array.length) {
			__array.insert(index, element);
		}
	}

	public function iterator():Iterator<T> {
		return __array.iterator();
	}

	public function join(sep:String = ","):String {
		return __array.join(sep);
	}

	public function lastIndexOf(x:T, ?from:Int = 0):Int {
		var i = __array.length - 1;

		while (i >= from) {
			if (__array[i] == x)
				return i;
			i--;
		}

		return -1;
	}

	public function pop():T {
		if (!fixed) {
			return __array.pop();
		} else {
			return null;
		}
	}

	public function push(x:T):Int {
		if (!fixed) {
			return __array.push(x);
		} else {
			return __array.length;
		}
	}

	public function removeAt(index:Int):T {
		if (!fixed || index < __array.length) {
			return __array.splice(index, 1)[0];
		}

		return null;
	}

	public function reverse():IVector<T> {
		__array.reverse();
		return this;
	}

	public function set(index:Int, value:T):T {
		if (!fixed || index < __array.length) {
			return __array[index] = value;
		} else {
			return value;
		}
	}

	public function shift():T {
		if (!fixed) {
			return __array.shift();
		} else {
			return null;
		}
	}

	public function slice(?startIndex:Int = 0, ?endIndex:Int = 16777215):IVector<T> {
		return new ObjectVector(__array.slice(startIndex, endIndex));
	}

	public function sort(f:T->T->Int):Void {
		__array.sort(f);
	}

	public function splice(pos:Int, len:Int):IVector<T> {
		return new ObjectVector(__array.splice(pos, len));
	}

	@:noCompletion @:keep private function toJSON() {
		return __array;
	}

	public function toString():String {
		return __array != null ? __array.toString() : null;
	}

	public function unshift(x:T):Void {
		if (!fixed) {
			__array.unshift(x);
		}
	}

	// Getters & Setters

	@:noCompletion private function get_length():Int {
		return __array.length;
	}

	@:noCompletion private function set_length(value:Int):Int {
		if (!fixed) {
			#if cpp
			cpp.NativeArray.setSize(__array, value);
			#else
			var currentLength = __array.length;
			if (value < 0)
				value = 0;

			if (value > currentLength) {
				for (i in currentLength...value) {
					__array.push(null);
				}
			} else {
				while (__array.length > value) {
					__array.pop();
				}
			}
			#end
		}

		return __array.length;
	}
}

private interface IVector<T> {
	var fixed:Bool;
	var length(get, set):Int;

	function concat(?a:IVector<T>):IVector<T>;
	function filter(callback:T->Bool):IVector<T>;
	function copy():IVector<T>;
	function get(index:Int):T;
	function indexOf(x:T, ?from:Int = 0):Int;
	function insertAt(index:Int, element:T):Void;
	function iterator():Iterator<T>;
	function join(sep:String = ","):String;
	function lastIndexOf(x:T, ?from:Int = 0):Int;
	function pop():Null<T>;
	function push(x:T):Int;
	function removeAt(index:Int):T;
	function reverse():IVector<T>;
	function set(index:Int, value:T):T;
	function shift():Null<T>;
	function slice(?pos:Int, ?end:Int):IVector<T>;
	function sort(f:T->T->Int):Void;
	function splice(pos:Int, len:Int):IVector<T>;
	function toString():String;
	function unshift(x:T):Void;

	private function toJSON():Dynamic;
}
