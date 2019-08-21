package openfl._internal.renderer.canvas;


import openfl._internal.renderer.AbstractMaskManager;
import openfl.display.*;
import openfl.geom.*;

@:access(openfl.display.DisplayObject)
@:keep


class CanvasMaskManager extends AbstractMaskManager {
	
	
	public function new (renderSession:RenderSession) {
		
		super (renderSession);
		
	}
	
	
	public function pushMask (mask:DisplayObject):Void {
		
		renderSession.context.save ();
		mask.__canvasPushMask (renderSession);
		
	}
	
	
	public override function pushObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		if (handleScrollRect && object.__scrollRect != null) {
			
			pushRect (object.__scrollRect, object.__renderTransform);
			
		}
		
		if (!object.__cacheBitmapRender && object.__mask != null) {
			
			pushMask (object.__mask);
			
		}
		
	}
	
	
	public override function pushRect (rect:Rectangle, transform:Matrix):Void {
		
		var context = renderSession.context;
		context.save ();
		
		var pixelRatio = renderSession.pixelRatio;
		context.setTransform (transform.a * pixelRatio, transform.b, transform.c, transform.d * pixelRatio, transform.tx * pixelRatio, transform.ty * pixelRatio);
		
		context.beginPath ();
		context.rect (rect.x, rect.y, rect.width, rect.height);
		context.clip ();
		
	}
	
	
	public function popMask (mask:DisplayObject):Void {
		
		mask.__canvasPopMask(renderSession);
		renderSession.context.restore ();
		
	}
	
	
	public override function popObject (object:DisplayObject, handleScrollRect:Bool = true):Void {
		
		if (!object.__cacheBitmapRender && object.__mask != null) {
			
			popMask (object.__mask);
			
		}
		
		if (handleScrollRect && object.__scrollRect != null) {
			
			popRect ();
			
		}
		
	}
	
	
	public override function popRect ():Void {
		
		renderSession.context.restore ();
		
	}
	
	
}