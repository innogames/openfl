package lime.graphics;

import js.Browser;
import lime.app.Event;
import lime.math.Rectangle;
import lime.ui.Window;
import lime._backend.html5.HTML5Renderer;

@:access(lime.ui.Window)
@:access(lime._backend.html5.HTML5Renderer.context)
class Renderer {
	public var context:GLRenderContext;
	public var onContextLost = new Event<Void->Void>();
	public var onContextRestored = new Event<GLRenderContext->Void>();
	public var window:Window;
	public var hasMajorPerformanceCaveat:Bool;

	public function new(window:Window) {
		this.window = window;
	}

	public function create():Void {
		createContext();

		window.backend.canvas.addEventListener("webglcontextlost", handleEvent, false);
		window.backend.canvas.addEventListener("webglcontextrestored", handleEvent, false);
	}

	private function createContext():Void {
		if (window.backend.canvas == null) {
			return;
		}

		var transparentBackground = Reflect.hasField(window.config, "background") && window.config.background == null;
		var colorDepth = Reflect.hasField(window.config, "colorDepth") ? window.config.colorDepth : 16;

		var options = {
			alpha: (transparentBackground || colorDepth > 16) ? true : false,
			antialias: Reflect.hasField(window.config, "antialiasing") ? window.config.antialiasing > 0 : false,
			depth: Reflect.hasField(window.config, "depthBuffer") ? window.config.depthBuffer : true,
			premultipliedAlpha: true,
			stencil: Reflect.hasField(window.config, "stencilBuffer") ? window.config.stencilBuffer : false,
			preserveDrawingBuffer: false,
			failIfMajorPerformanceCaveat: true
		};

		for (highPerf in [true, false]) {
			options.failIfMajorPerformanceCaveat = highPerf;
			hasMajorPerformanceCaveat = !highPerf;

			for (name in ["webgl2", "webgl", "experimental-webgl"]) {
				var webgl = window.backend.canvas.getContext(name, options);
				if (webgl != null) {
					context = HTML5Renderer.context = webgl;
					return;
				}
			}
		}
	}

	private function handleEvent(event:js.html.Event):Void {
		switch (event.type) {
			case "webglcontextlost":
				event.preventDefault();

				context = null;

				onContextLost.dispatch();

			case "webglcontextrestored":
				createContext();

				onContextRestored.dispatch(context);

			default:
		}
	}

	public function readPixels(rect:Rectangle = null):Image {
		// TODO: Handle DIV, improve 3D canvas support

		if (window.backend.canvas != null) {
			if (rect == null) {
				rect = new Rectangle(0, 0, window.backend.canvas.width, window.backend.canvas.height);
			} else {
				rect.__contract(0, 0, window.backend.canvas.width, window.backend.canvas.height);
			}

			if (rect.width > 0 && rect.height > 0) {
				var canvas = Browser.document.createCanvasElement();
				canvas.width = Std.int(rect.width);
				canvas.height = Std.int(rect.height);

				var context = canvas.getContext("2d");
				context.drawImage(window.backend.canvas, -rect.x, -rect.y);

				return Image.fromCanvas(canvas);
			}
		}

		return null;
	}
}
