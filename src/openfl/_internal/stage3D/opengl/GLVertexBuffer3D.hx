package openfl._internal.stage3D.opengl;

import lime.graphics.opengl.GL;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import openfl.Vector;
import openfl._internal.renderer.opengl.GLRenderSession;
import openfl._internal.stage3D.GLUtils;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.VertexBuffer3D;
import openfl.utils.ByteArray;

@:access(openfl.display3D.VertexBuffer3D)
class GLVertexBuffer3D {
	public static function create(vertexBuffer:VertexBuffer3D, renderSession:GLRenderSession, bufferUsage:Context3DBufferUsage) {
		var gl = renderSession.gl;

		vertexBuffer.__stride = vertexBuffer.__vertexSize * 4;

		vertexBuffer.__id = gl.createBuffer();
		GLUtils.checkGLError(gl);

		vertexBuffer.__usage = (bufferUsage == Context3DBufferUsage.DYNAMIC_DRAW) ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW;

		// __context.__statsIncrement (Context3D.Context3DTelemetry.COUNT_VERTEX_BUFFER);
		// __memoryUsage = 0;
	}

	public static function dispose(vertexBuffer:VertexBuffer3D, renderSession:GLRenderSession):Void {
		var gl = renderSession.gl;

		if (gl.isBuffer(vertexBuffer.__id)) { // prevent the warning when the id becomes invalid after context loss+restore

			gl.deleteBuffer(vertexBuffer.__id);
		}

		// __context.__statsDecrement (Context3D.Context3DTelemetry.COUNT_VERTEX_BUFFER);
		// __context.__statsSubtract (Context3D.Context3DTelemetry.MEM_VERTEX_BUFFER, __memoryUsage);
		// __memoryUsage = 0;
	}

	public static function uploadFromByteArray(vertexBuffer:VertexBuffer3D, renderSession:GLRenderSession, data:ByteArray, byteArrayOffset:Int, startVertex:Int,
			numVertices:Int):Void {
		if (data == null)
			return;

		var offset = byteArrayOffset + startVertex * vertexBuffer.__stride;
		var length = numVertices * vertexBuffer.__vertexSize;

		uploadFromTypedArray(vertexBuffer, renderSession, new Float32Array(data, offset, length));
	}

	public static function uploadFromTypedArray(vertexBuffer:VertexBuffer3D, renderSession:GLRenderSession, data:ArrayBufferView):Void {
		var gl = renderSession.gl;

		gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer.__id);
		GLUtils.checkGLError(gl);

		gl.bufferData(GL.ARRAY_BUFFER, data, vertexBuffer.__usage);
		GLUtils.checkGLError(gl);

		// if (data.byteLength != __memoryUsage) {

		// 	__context.__statsAdd (Context3D.Context3DTelemetry.MEM_VERTEX_BUFFER, data.byteLength - __memoryUsage);
		// 	__memoryUsage = data.byteLength;

		// }
	}

	public static function uploadFromVector(vertexBuffer:VertexBuffer3D, renderSession:GLRenderSession, data:Vector<Float>, startVertex:Int,
			numVertices:Int):Void {
		if (data == null)
			return;

		var gl = renderSession.gl;

		// TODO: Optimize more

		var start = startVertex * vertexBuffer.__vertexSize;
		var count = numVertices * vertexBuffer.__vertexSize;
		var length = start + count;

		var existingFloat32Array = vertexBuffer.__tempFloat32Array;
		if (vertexBuffer.__tempFloat32Array == null || vertexBuffer.__tempFloat32Array.length < count) {
			vertexBuffer.__tempFloat32Array = new Float32Array(count);

			if (existingFloat32Array != null) {
				vertexBuffer.__tempFloat32Array.set(existingFloat32Array);
			}
		}

		for (i in start...length) {
			vertexBuffer.__tempFloat32Array[i - start] = data[i];
		}

		uploadFromTypedArray(vertexBuffer, renderSession, vertexBuffer.__tempFloat32Array);
	}
}
