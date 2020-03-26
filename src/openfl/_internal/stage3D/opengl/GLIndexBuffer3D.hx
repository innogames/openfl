package openfl._internal.stage3D.opengl;


import lime.graphics.opengl.GL;
import lime.utils.ArrayBufferView;
import lime.utils.Int16Array;
import openfl.Vector;
import openfl._internal.renderer.RenderSession;
import openfl._internal.stage3D.GLUtils;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.IndexBuffer3D;
import openfl.utils.ByteArray;


@:access(openfl.display3D.IndexBuffer3D)
class GLIndexBuffer3D {
	
	
	public static function create (indexBuffer:IndexBuffer3D, renderSession:RenderSession, bufferUsage:Context3DBufferUsage):Void {
		
		var gl = renderSession.gl;
		
		indexBuffer.__elementType = GL.UNSIGNED_SHORT;
		
		indexBuffer.__id = gl.createBuffer ();
		GLUtils.checkGLError (gl);
		
		indexBuffer.__usage = (bufferUsage == Context3DBufferUsage.DYNAMIC_DRAW) ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW;
		
		// __context.__statsIncrement (Context3D.Context3DTelemetry.COUNT_INDEX_BUFFER);
		// __memoryUsage = 0;
		
	}
	
	
	public static function dispose (indexBuffer:IndexBuffer3D, renderSession:RenderSession):Void {
		
		var gl = renderSession.gl;
		
		if (gl.isBuffer (indexBuffer.__id)) { // prevent the warning when the id becomes invalid after context loss+restore
			
			gl.deleteBuffer (indexBuffer.__id);
			
		}
		
		// __context.__statsDecrement(Context3D.Context3DTelemetry.COUNT_INDEX_BUFFER);
		// __context.__statsSubtract(Context3D.Context3DTelemetry.MEM_INDEX_BUFFER, __memoryUsage);
		// __memoryUsage = 0;
		
	}
	
	
	public static function uploadFromByteArray (indexBuffer:IndexBuffer3D, renderSession:RenderSession, data:ByteArray, byteArrayOffset:Int, startOffset:Int, count:Int):Void {
		
		var offset = byteArrayOffset + startOffset * 2;
		
		uploadFromTypedArray (indexBuffer, renderSession, new Int16Array (data.toArrayBuffer (), offset, count));
		
	}
	
	
	public static function uploadFromTypedArray (indexBuffer:IndexBuffer3D, renderSession:RenderSession, data:ArrayBufferView):Void {
		
		if (data == null) return;
		var gl = renderSession.gl;
		
		gl.bindBuffer (GL.ELEMENT_ARRAY_BUFFER, indexBuffer.__id);
		GLUtils.checkGLError (gl);
		
		gl.bufferData (GL.ELEMENT_ARRAY_BUFFER, data, indexBuffer.__usage);
		GLUtils.checkGLError (gl);
		
		// if (data.byteLength != __memoryUsage) {
			
		// 	__context.__statsAdd (Context3D.Context3DTelemetry.MEM_INDEX_BUFFER, data.byteLength - __memoryUsage);
		// 	__memoryUsage = data.byteLength;
			
		// }
		
	}
	
	
	public static function uploadFromVector (indexBuffer:IndexBuffer3D, renderSession:RenderSession, data:Vector<UInt>, startOffset:Int, count:Int):Void {
		
		// TODO: Optimize more
		
		if (data == null) return;
		var gl = renderSession.gl;
		
		var length = startOffset + count;
		var existingInt16Array = indexBuffer.__tempInt16Array;
		
		if (indexBuffer.__tempInt16Array == null || indexBuffer.__tempInt16Array.length < count) {
			
			indexBuffer.__tempInt16Array = new Int16Array (count);
			
			if (existingInt16Array != null) {
				
				indexBuffer.__tempInt16Array.set (existingInt16Array);
				
			}
			
		}
		
		for (i in startOffset...length) {
			
			indexBuffer.__tempInt16Array[i - startOffset] = data[i];
			
		}
		
		uploadFromTypedArray (indexBuffer, renderSession, indexBuffer.__tempInt16Array);
		
	}
	
	
}