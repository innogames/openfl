package openfl.external;

import haxe.Constraints.Function;
import lime.app.Application;

private typedef CallbackCollection = haxe.DynamicAccess<Function>;

@:access(openfl.display.Stage)
@:access(lime.ui.Window)
final class ExternalInterface {
	public static var available(default, null) = true;
	public static var marshallExceptions = false;
	public static var objectID(default, null):String;

	public static function addCallback(functionName:String, closure:Function):Void {
		if (Application.current.window.backend.element != null) {
			(cast Application.current.window.backend.element : CallbackCollection)[functionName] = closure;
		}
	}

	public static function call(functionName:String, ?p1:Dynamic, ?p2:Dynamic, ?p3:Dynamic, ?p4:Dynamic, ?p5:Dynamic):Dynamic {
		var callResponse:Dynamic = null;

		if (!~/^\(.+\)$/.match(functionName)) {
			var thisArg = functionName.split('.').slice(0, -1).join('.');
			if (thisArg.length > 0) {
				functionName += '.bind(${thisArg})';
			}
		}

		// Flash does not throw an error or attempt to execute
		// if the function does not exist.
		var fn:Dynamic;
		try {
			fn = js.Lib.eval(functionName);
		} catch (e:Dynamic) {
			return null;
		}
		if (Type.ValueType.TFunction != Type.typeof(fn)) {
			return null;
		}

		if (p1 == null) {
			callResponse = fn();
		} else if (p2 == null) {
			callResponse = fn(p1);
		} else if (p3 == null) {
			callResponse = fn(p1, p2);
		} else if (p4 == null) {
			callResponse = fn(p1, p2, p3);
		} else if (p5 == null) {
			callResponse = fn(p1, p2, p3, p4);
		} else {
			callResponse = fn(p1, p2, p3, p4, p5);
		}

		return callResponse;
	}
}
