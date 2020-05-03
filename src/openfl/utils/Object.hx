package openfl.utils;

@:forward() abstract Object(ObjectType) from ObjectType {
	public inline function new() {
		this = {};
	}

	public inline function hasOwnProperty(name:String):Bool {
		return (this != null && Reflect.hasField(this, name));
	}

	public inline function isPrototypeOf(theClass:Class<Dynamic>):Bool {
		var c = Type.getClass(this);

		while (c != null) {
			if (c == theClass)
				return true;
			c = Type.getSuperClass(c);
		}

		return false;
	}

	@:noCompletion @:dox(hide) public function iterator():Iterator<String> {
		var fields = Reflect.fields(this);
		if (fields == null)
			fields = [];
		return fields.iterator();
	}

	public inline function propertyIsEnumerable(name:String):Bool {
		return (this != null && Reflect.hasField(this, name));
	}

	public inline function toLocaleString():String {
		return Std.string(this);
	}

	@:to public inline function toString():String {
		return Std.string(this);
	}

	public inline function valueOf():Object {
		return this;
	}

	@:arrayAccess @:noCompletion @:dox(hide) public inline function __get(key:String):Dynamic {
		return Reflect.field(this, key);
	}

	@:arrayAccess @:noCompletion @:dox(hide) public inline function __set(key:String, value:Dynamic):Dynamic {
		Reflect.setField(this, key, value);
		return value;
	}
}

#if !flash
typedef ObjectType = Dynamic;
#else
typedef ObjectType = flash.utils.Object;
#end
