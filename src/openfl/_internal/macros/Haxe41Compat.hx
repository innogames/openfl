package openfl._internal.macros;

// this is a temporary hack to make it work with pre-haxe.Exception haxe 4.1 commits
// to be removed soon
class Haxe41Compat {
	public static macro function getLastCaughtJSError() {
		// latest haxe 4.1
		var e = macro @:privateAccess haxe.NativeStackTrace.lastError;
		try {
			haxe.macro.Context.typeof(e); // will throw an error
			return e;
		} catch (e:Any) {
			// pre-haxe.Exception versions
			return macro @:privateAccess haxe.CallStack.lastException;
		}
	}
}
