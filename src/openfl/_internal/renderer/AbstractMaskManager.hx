package openfl._internal.renderer;


import openfl.display.*;
import openfl.geom.*;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.DisplayObject)
@:keep


class AbstractMaskManager {
	
	
	private var renderSession:RenderSession;
	
	
	public function new (renderSession:RenderSession) {
		
		this.renderSession = renderSession;
		
	}
	
	
	public function pushObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		
		
	}
	
	
	public function pushRect (rect:Rectangle, transform:Matrix):Void {
		
		
		
	}
	
	
	public function popObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		
		
	}
	
	
	public function popRect ():Void {
		
		
		
	}
	
	
	public function saveState ():Void {
		
		
		
	}
	
	
	public function restoreState ():Void {
		
		
		
	}
	
	
}