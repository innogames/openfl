package openfl._internal.utils; #if macro


import haxe.macro.Compiler;
import haxe.macro.Context;


class ExtraParams {
	
	
	public static function include ():Void {
		
		if (!Context.defined ("tools")) {
			
			if (!Context.defined ("flash")) {
				
				Compiler.allowPackage ("flash");
				Compiler.define ("swf-version", "22.0");
				
			}
			
		}
		
	}
	
}


#end