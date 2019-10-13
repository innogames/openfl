package lime.graphics;


import lime.graphics.CanvasRenderContext;
import lime.graphics.GLRenderContext;


enum RenderContext {
	
	OPENGL (gl:#if (!flash || display) GLRenderContext #else Dynamic #end);
	CANVAS (context:CanvasRenderContext);
	
}