package openfl._internal.renderer.opengl;

import lime.graphics.GLRenderContext;
import openfl._internal.renderer.opengl.batcher.BatchRenderer;
import openfl._internal.renderer.opengl.vao.IVertexArrayObjectContext;
import openfl._internal.renderer.opengl.vao.VertexArrayObjectContext;
import openfl._internal.renderer.opengl.vao.VertexArrayObjectExtension;
import openfl._internal.stage3D.GLUtils;

class GLRenderSession extends RenderSession {
	public final renderer:GLRenderer;
	public final gl:GLRenderContext;
	public final shaderManager:GLShaderManager;
	public final batcher:BatchRenderer;

	#if vertex_array_object
	public final vaoContext:Null<IVertexArrayObjectContext>;
	#end

	public function new(renderer, gl) {
		super(true);
		this.renderer = renderer;
		this.gl = gl;

		maskManager = new GLMaskManager(this);
		
		var blendModeManager = new GLBlendModeManager(gl);
		this.blendModeManager = blendModeManager;

		var shaderManager = new GLShaderManager(gl);
		this.shaderManager = shaderManager;

		batcher = new BatchRenderer(gl, blendModeManager, shaderManager, 4096);

		#if vertex_array_object
		vaoContext = initVao();
		#end
	}

	#if vertex_array_object
	function initVao():Null<IVertexArrayObjectContext> {
		if (GLUtils.isWebGL2(gl)) {
			return new VertexArrayObjectContext(gl);
		}

		var vaoExtension = gl.getExtension("OES_vertex_array_object");
		if (vaoExtension != null) {
			return new VertexArrayObjectExtension(vaoExtension);
		}

		return null;
	}
	#end
}
