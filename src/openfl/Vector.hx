package openfl;

import openfl.errors.RangeError;

abstract Vector<T>(VectorData<T>) from VectorData<T> {

	public var fixed (get, set):Bool;
	public var length (get, set):Int;

	public function new(length = 0, fixed = false) {
		var array = [];
		array.resize(length);
		this = new VectorData(array, fixed);
	}

	public inline function concat(?other:Vector<T>):Vector<T> {
		return new VectorData<T>(if (other == null) this.array.copy() else this.array.concat(other.array), false);
	}

	public inline function copy():Vector<T> {
		return new VectorData<T>(this.array.copy(), true);
	}

	public inline function filter(callback:T->Bool):Vector<T> {
		return new VectorData<T>(this.array.filter(callback), false);
	}

	public inline function map<S>(callback:T->S):Vector<S> {
		return new VectorData<S>(this.array.map(callback), false);
	}

	public inline function indexOf(searchElement:T, fromIndex:Int = 0):Int {
		return this.array.indexOf(searchElement, fromIndex);
	}

	public inline function insertAt(index:Int, element:T):Void {
		this.checkNotFixed();
		return this.array.insert(index, element);
	}

	public inline function join(sep = ","):String {
		return this.array.join(sep);
	}

	public inline function lastIndexOf(searchElement:T, fromIndex:Int = 0x7fffffff):Int {
		return this.array.lastIndexOf(searchElement, fromIndex);
	}

	public inline function pop():T {
		this.checkNotFixed();
		return this.array.pop();
	}

	public inline function push(element:T):Int {
		this.checkNotFixed();
		return this.array.push(element);
	}

	public inline function removeAt(index:Int):T {
		this.checkNotFixed();
		return this.array.splice(index, 1)[0];
	}

	public inline function reverse():Vector<T> {
		this.array.reverse();
		return this;
	}

	public inline function shift():T {
		this.checkNotFixed();
		return this.array.shift();
	}

	public inline function slice(startIndex:Int = 0, endIndex:Int = 16777215):Vector<T> {
		return new VectorData<T>(this.array.slice(startIndex, endIndex), false);
	}

	public inline function sort(f:(a:T, b:T)->Int):Void {
		this.array.sort(f);
	}

	public inline function splice(startIndex:Int, deleteCount:Int):Vector<T> {
		this.checkNotFixed();
		return new VectorData(this.array.splice(startIndex, deleteCount), false);
	}

	public inline function toString():String {
		return this.array.toString();
	}

	public inline function unshift(element:T):Void {
		this.checkNotFixed();
		this.array.unshift(element);
	}

	public inline function iterator():ArrayIterator<T> return this.iterator();

	public static inline function ofArray<T>(a:Array<T>):Vector<T> {
		return new VectorData(a.copy(), false);
	}

	public inline static function isVector(value:Dynamic):Bool {
		return Std.is(value, VectorData);
	}

	public inline static function convert<T,S>(v:Vector<T>):Vector<S> {
		return cast v;
	}

	@:arrayAccess inline function get(index:Int):T {
		return this.array[index];
	}

	@:arrayAccess inline function set(index:Int, value:T):T {
		return this.array[index] = value;
	}

	// private

	var array(get,never):Array<T>;
	inline function get_array():Array<T> return this.array;

	inline function get_fixed():Bool return this.fixed;
	inline function set_fixed(value:Bool):Bool return this.fixed = value;

	inline function get_length():Int return this.array.length;
	inline function set_length(value:Int):Int {
		this.checkNotFixed();
		this.array.resize(value);
		return value;
	}
}

private class VectorData<T> {
	@:native("data")
	public var array:Array<T>;
	public var fixed:Bool;

	public inline function new(array:Array<T>, fixed:Bool) {
		this.array = array;
		this.fixed = fixed;
	}

	public inline function iterator():ArrayIterator<T> {
		return new ArrayIterator<T>(array);
	}

	public inline function checkNotFixed() {
		// if (fixed) throw new RangeError("Vector is fixed!");
	}
}

private class ArrayIterator<T> {
	public var array:Array<T>;
	public var length:Int;
	public var index:Int;

	public inline function new(array:Array<T>) {
		this.array = array;
		this.length = array.length;
		this.index = 0;
	}

	public inline function hasNext():Bool {
		return index < length;
	}

	public inline function next():T {
		return array[index++];
	}
}
