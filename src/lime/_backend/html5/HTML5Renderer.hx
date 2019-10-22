package lime._backend.html5;


import js.Browser;
import lime.graphics.GLRenderContext;

// TODO: remove static context
// TODO: expose debug function at run-time
// (and finally remove HTML5Renderer)
class HTML5Renderer {
	
	
	public static var context (default, null):GLRenderContext;

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
	
	
}
