package openfl.display3D;
import openfl._internal.utils.NullUtils;


@:enum abstract Context3DRenderMode(Null<Int>) {
	
	public var AUTO = 0;
	public var SOFTWARE = 1;
	
	@:from private static function fromString (value:String):Context3DRenderMode {
		
		return switch (value) {
			
			case "auto": AUTO;
			case "software": SOFTWARE;
			default: null;
			
		}
		
	}
	
	@:to private function toString ():String {
		
		return switch (cast this) {
			
			case Context3DRenderMode.AUTO: "auto";
			case Context3DRenderMode.SOFTWARE: "software";
			default: null;
			
		}
		
	}
	
	#if cs
	@:noCompletion @:op(A == B) private static function equals (a:Context3DRenderMode, b:Context3DRenderMode):Bool {
		
		return NullUtils.valueEquals (a, b, Int);
		
	}
	#end
	
	#if cs
	@:noCompletion @:op(A != B) private static function notEquals (a:Context3DRenderMode, b:Context3DRenderMode):Bool {
		
		return !equals (a, b);
		
	}
	#end
	
}