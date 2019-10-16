package lime.graphics;


import lime.app.Event;
import lime.math.Rectangle;
import lime.ui.Window;
import lime._backend.html5.HTML5Renderer as RendererBackend;

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class Renderer {
	
	
	public var context:GLRenderContext;
	public var onContextLost = new Event<Void->Void> ();
	public var onContextRestored = new Event<GLRenderContext->Void> ();
	public var window:Window;
	
	@:noCompletion private var backend:RendererBackend;
	
	
	public function new (window:Window) {
		
		this.window = window;
		
		backend = new RendererBackend (this);
		
	}
	
	
	public function create ():Void {
		
		backend.create ();
		
	}
	
	
	public function readPixels (rect:Rectangle = null):Image {
		
		return backend.readPixels (rect);
		
	}
	
	
}
