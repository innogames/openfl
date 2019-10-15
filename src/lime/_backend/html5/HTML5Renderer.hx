package lime._backend.html5;


import js.html.webgl.RenderingContext;
import js.html.CanvasElement;
import js.Browser;
import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.GLRenderContext;
import lime.graphics.Renderer;
import lime.math.Rectangle;

@:access(lime._backend.html5.HTML5Window)
@:access(lime.app.Application)
@:access(lime.graphics.GLRenderContext)
@:access(lime.graphics.Renderer)
@:access(lime.ui.Window)


class HTML5Renderer {
	
	public static var context (default, null):GLRenderContext;

	public static function getWebGLVersion(gl:GLRenderContext):Int {
		if (Reflect.hasField(js.Browser.window, "WebGL2RenderingContext") && Std.is(gl, js.html.webgl.WebGL2RenderingContext)) {
			return 2;
		}
		return 1;
	}

	#if debug
	static var __lastLoseContextExtension:Dynamic;
	
	@:expose("loseGLContext")
	static function loseContext() {
		var extension = context.getExtension('WEBGL_lose_context');
		if (extension == null) {
			js.Browser.console.warn("Context already lost");
		} else {
			extension.loseContext();
			__lastLoseContextExtension = extension;
		}
	}
	
	@:expose("restoreGLContext")
	static function restoreContext() {
		if (__lastLoseContextExtension == null) {
			js.Browser.console.warn("No lost context found"); // yeah
		} else {
			__lastLoseContextExtension.restoreContext();
			__lastLoseContextExtension = null;
		}
	}
	#end
	
	private var parent:Renderer;
	
	
	public function new (parent:Renderer) {
		
		this.parent = parent;
		
	}
	
	
	public function create ():Void {
		
		createContext ();
		
		parent.window.backend.canvas.addEventListener ("webglcontextlost", handleEvent, false);
		parent.window.backend.canvas.addEventListener ("webglcontextrestored", handleEvent, false);
		
	}
	
	
	private function createContext ():Void {
		
		if (parent.window.backend.canvas != null) {
			
			var transparentBackground = Reflect.hasField (parent.window.config, "background") && parent.window.config.background == null;
			var colorDepth = Reflect.hasField (parent.window.config, "colorDepth") ? parent.window.config.colorDepth : 16;
			
			var options = {
				
				alpha: (transparentBackground || colorDepth > 16) ? true : false,
				antialias: Reflect.hasField (parent.window.config, "antialiasing") ? parent.window.config.antialiasing > 0 : false,
				depth: Reflect.hasField (parent.window.config, "depthBuffer") ? parent.window.config.depthBuffer : true,
				premultipliedAlpha: true,
				stencil: Reflect.hasField (parent.window.config, "stencilBuffer") ? parent.window.config.stencilBuffer : false,
				preserveDrawingBuffer: false
				
			};
			
			for (name in [ "webgl2", "webgl", "experimental-webgl" ]) {

				var webgl = parent.window.backend.canvas.getContext (name, options);
				if (webgl != null) {
					context = parent.context = webgl;
					break;
				}
				
			}
			
		}
		
	}
	
	
	public function flip ():Void {
		
		
		
	}
	
	
	private function handleEvent (event:js.html.Event):Void {
		
		switch (event.type) {
			
			case "webglcontextlost":
				
				event.preventDefault ();
				
				parent.context = null;
				
				parent.onContextLost.dispatch ();
				
			case "webglcontextrestored":
				
				createContext ();
				
				parent.onContextRestored.dispatch (parent.context);
			
			default:
			
		}
		
	}
	
	
	public function readPixels (rect:Rectangle):Image {
		
		// TODO: Handle DIV, improve 3D canvas support
		
		if (parent.window.backend.canvas != null) {
			
			if (rect == null) {
				
				rect = new Rectangle (0, 0, parent.window.backend.canvas.width, parent.window.backend.canvas.height);
				
			} else {
				
				rect.__contract (0, 0, parent.window.backend.canvas.width, parent.window.backend.canvas.height);
				
			}
			
			if (rect.width > 0 && rect.height > 0) {
				
				var canvas:CanvasElement = cast Browser.document.createElement ("canvas");
				canvas.width = Std.int (rect.width);
				canvas.height = Std.int (rect.height);
				
				var context = canvas.getContext ("2d");
				context.drawImage (parent.window.backend.canvas, -rect.x, -rect.y);
				
				return Image.fromCanvas (canvas);
				
			}
			
		}
		
		return null;
		
	}
	
	
	public function render ():Void {
		
		
		
	}
	
	
}