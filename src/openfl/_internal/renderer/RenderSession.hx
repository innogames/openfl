package openfl._internal.renderer;

import lime.graphics.CanvasRenderContext;
import lime.graphics.GLRenderContext;
import openfl._internal.stage3D.GLUtils;
import openfl._internal.renderer.opengl.GLShaderManager;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.opengl.batcher.BatchRenderer;
import openfl._internal.renderer.opengl.vao.VertexArrayObjectExtension;
import openfl._internal.renderer.opengl.vao.VertexArrayObjectContext;
import openfl._internal.renderer.opengl.vao.IVertexArrayObjectContext;

class RenderSession {
	public var allowSmoothing:Bool;
	public var clearRenderDirty:Bool;
	public var context:CanvasRenderContext;
	public var element:js.html.DivElement;
	public var forceSmoothing:Bool;
	public var gl(default, set):GLRenderContext;
	public var vaoContext:IVertexArrayObjectContext;
	public var renderer:GLRenderer;
	public var batcher:BatchRenderer;
	public var roundPixels:Bool;
	public var pixelRatio:Float = 1.0;
	public var blendModeManager:AbstractBlendModeManager;
	public var maskManager:AbstractMaskManager;
	public var shaderManager:GLShaderManager;

	function set_gl(gl:GLRenderContext):GLRenderContext {
		this.gl = gl;

		#if vertex_array_object
		if (GLUtils.isWebGL2(gl)) {
			vaoContext = new VertexArrayObjectContext(gl);
		} else {
			var vaoExtension = gl.getExtension("OES_vertex_array_object");
			if (vaoExtension != null) {
				vaoContext = new VertexArrayObjectExtension(vaoExtension);
			}
		}
		#end

		return gl;
	}

	public function new() {
		allowSmoothing = true;
		clearRenderDirty = false;
	}
}
