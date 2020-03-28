package openfl.errors;

#if (haxe < version("4.1.0-rc.1"))
import haxe.CallStack;

class Error {
	public var errorID(default, null):Int;
	public var message:String;
	public var name:String;

	public function new(message:String = "", id:Int = 0) {
		this.message = message;
		this.errorID = id;
		name = "Error";
	}

	public function getStackTrace():String {
		return CallStack.toString(CallStack.exceptionStack());
	}

	public function toString():String {
		if (message != null) {
			return message;
		} else {
			return "Error";
		}
	}
}
#else
class Error extends haxe.Exception {
	public var errorID(default, null):Int;
	public var name:String;

	public function new(message:String = "", id:Int = 0) {
		super(message);
		this.errorID = id;
		name = "Error";
	}

	public function getStackTrace():String {
		return stack.toString();
	}

	override function toString():String {
		if (message != null) {
			return message;
		} else {
			return "Error";
		}
	}
}
#end
