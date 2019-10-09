package openfl._internal.renderer.opengl.batcher;

import lime.graphics.GLRenderContext;

#if js
import js.html.webgl.extension.ANGLEInstancedArrays;
#end

interface InstancedRendering {
	function drawArraysInstanced(mode:Int, first:Int, count:Int, primcount:Int):Void;
	function vertexAttribDivisor(index:Int, divisor:Int):Void;
}

class GLInstancedRendering implements InstancedRendering {
	final gl:GLRenderContext;
	
	public function new(gl) {
		this.gl = gl;
	}

	public function drawArraysInstanced(mode:Int, first:Int, count:Int, primcount:Int) {
		gl.drawArraysInstanced(mode, first, count, primcount);
	}
	
	public function vertexAttribDivisor(index:Int, divisor:Int) {
		gl.vertexAttribDivisor(index, divisor);
	}
}

#if js
class WebGLANGLEInstancedRendering implements InstancedRendering {
	final ext:ANGLEInstancedArrays;
	
	public function new(ext) {
		this.ext = ext;
	}

	public function drawArraysInstanced(mode:Int, first:Int, count:Int, primcount:Int) {
		ext.drawArraysInstancedANGLE(mode, first, count, primcount);
	}
	
	public function vertexAttribDivisor(index:Int, divisor:Int) {
		ext.vertexAttribDivisorANGLE(index, divisor);
	}
}
#end
