package lime._backend.html5;


import haxe.io.Bytes;
import haxe.Int64;
import js.html.webgl.WebGL2RenderingContext;
import js.html.CanvasElement;
import js.Browser;
import lime.graphics.opengl.*;
import lime.utils.ArrayBufferView;
import lime.utils.DataPointer;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt32Array;

@:allow(lime.ui.Window)


@:dce
class HTML5GLRenderContext {
	
	#if (js && html5)
	public var canvas (get, never):CanvasElement;
	public var drawingBufferHeight (get, never):Int;
	public var drawingBufferWidth (get, never):Int;
	#end
	
	public var version (default, null):Int;
	
	@:allow(openfl) // TODO: temporary
	private var __context:WebGL2RenderingContext;
	private var __contextLost:Bool;
	
	
	private function new (context:WebGL2RenderingContext) {
		
		__context = context;
		version = 1;
		
		if (context != null) {
			
			var gl = context;
			
			if (Reflect.hasField (gl, "rawgl")) {
				
				gl = Reflect.field (context, "rawgl");
				
			}
			
			if (Reflect.hasField (Browser.window, "WebGL2RenderingContext") && Std.is (gl, WebGL2RenderingContext)) {
				
				version = 2;
				
			}
			
		}
		
	}
	
	
	public inline function activeTexture (texture:Int):Void {
		
		__context.activeTexture (texture);
		
	}
	
	
	public inline function attachShader (program:GLProgram, shader:GLShader):Void {
		
		__context.attachShader (program, shader);
		
	}
	
	
	public inline function beginQuery (target:Int, query:GLQuery):Void {
		
		__context.beginQuery (target, query);
		
	}
	
	
	public inline function beginTransformFeedback (primitiveNode:Int):Void {
		
		__context.beginTransformFeedback (primitiveNode);
		
	}
	
	
	public inline function bindAttribLocation (program:GLProgram, index:Int, name:String):Void {
		
		__context.bindAttribLocation (program, index, name);
		
	}
	
	
	public inline function bindBuffer (target:Int, buffer:GLBuffer):Void {
		
		__context.bindBuffer (target, buffer);
		
	}
	
	
	public inline function bindBufferBase (target:Int, index:Int, buffer:GLBuffer):Void {
		
		__context.bindBufferBase (target, index, buffer);
		
	}
	
	
	public inline function bindBufferRange (target:Int, index:Int, buffer:GLBuffer, offset:DataPointer, size:Int):Void {
		
		__context.bindBufferRange (target, index, buffer, offset.toValue (), size);
		
	}
	
	
	public inline function bindFramebuffer (target:Int, framebuffer:GLFramebuffer):Void {
		
		__context.bindFramebuffer (target, framebuffer);
		
	}
	
	
	public inline function bindRenderbuffer (target:Int, renderbuffer:GLRenderbuffer):Void {
		
		__context.bindRenderbuffer (target, renderbuffer);
		
	}
	
	
	public inline function bindSampler (unit:Int, sampler:GLSampler):Void {
		
		__context.bindSampler (unit, sampler);
		
	}
	
	
	public inline function bindTexture (target:Int, texture:GLTexture):Void {
		
		__context.bindTexture (target, texture);
		
	}
	
	
	public inline function bindTransformFeedback (target:Int, transformFeedback:GLTransformFeedback):Void {
		
		__context.bindTransformFeedback (target, transformFeedback);
		
	}
	
	
	public inline function bindVertexArray (vertexArray:GLVertexArrayObject):Void {
		
		__context.bindVertexArray (vertexArray);
		
	}
	
	
	public inline function blendColor (red:Float, green:Float, blue:Float, alpha:Float):Void {
		
		__context.blendColor (red, green, blue, alpha);
		
	}
	
	
	public inline function blendEquation (mode:Int):Void {
		
		__context.blendEquation (mode);
		
	}
	
	
	public inline function blendEquationSeparate (modeRGB:Int, modeAlpha:Int):Void {
		
		__context.blendEquationSeparate (modeRGB, modeAlpha);
		
	}
	
	
	public inline function blendFunc (sfactor:Int, dfactor:Int):Void {
		
		__context.blendFunc (sfactor, dfactor);
		
	}
	
	
	public inline function blendFuncSeparate (srcRGB:Int, dstRGB:Int, srcAlpha:Int, dstAlpha:Int):Void {
		
		__context.blendFuncSeparate (srcRGB, dstRGB, srcAlpha, dstAlpha);
		
	}
	
	
	public inline function blitFramebuffer (srcX0:Int, srcY0:Int, srcX1:Int, srcY1:Int, dstX0:Int, dstY0:Int, dstX1:Int, dstY1:Int, mask:Int, filter:Int):Void {
		
		__context.blitFramebuffer (srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
		
	}
	
	
	public inline function bufferData (target:Int, size:Int, data:ArrayBufferView, usage:Int):Void {
		
		__context.bufferData (target, data, usage);
		
	}
	
	
	//public function bufferData (target:Int, srcData:ArrayBufferView, usage:Int):Void {
	//public function bufferData (target:Int, srcData:ArrayBuffer, usage:Int):Void {
	//public function bufferData (target:Int, size:Int, usage:Int):Void {
	//public function bufferData (target:Int, srcData:ArrayBufferView, usage:Int, srcOffset:Int = 0, length:Int = 0):Void {
	public function bufferDataWEBGL (target:Int, srcData:Dynamic, usage:Int, ?srcOffset:Int, ?length:Int):Void {
		
		if (srcOffset != null) {
			
			__context.bufferData (target, srcData, usage, srcOffset, length);
			
		} else {
			
			__context.bufferData (target, srcData, usage);
			
		}
		
	}
	
	
	public inline function bufferSubData (target:Int, dstByteOffset:Int, size:Int, data:DataPointer):Void {
		
		__context.bufferSubData (target, dstByteOffset, data.toBufferView (size));
		
	}
	
	
	//public function bufferSubData (target:Int, dstByteOffset:Int, srcData:ArrayBufferView):Void {
	//public function bufferSubData (target:Int, dstByteOffset:Int, srcData:ArrayBuffer):Void {
	//public function bufferSubData (target:Int, dstByteOffset:Int, srcData:ArrayBufferView, srcOffset:Int = 0, length:Int = 0):Void {
	public function bufferSubDataWEBGL (target:Int, dstByteOffset:Int, srcData:Dynamic, ?srcOffset:Int, ?length:Int):Void {
		
		if (srcOffset != null) {
			
			__context.bufferSubData (target, dstByteOffset, srcData, srcOffset, length);
			
		} else {
			
			__context.bufferSubData (target, dstByteOffset, srcData);
			
		}
		
	}
	
	
	public inline function checkFramebufferStatus (target:Int):Int {
		
		return __context.checkFramebufferStatus (target);
		
	}
	
	
	public inline function clear (mask:Int):Void {
		
		__context.clear (mask);
		
	}
	
	
	public inline function clearBufferfi (buffer:Int, drawbuffer:Int, depth:Float, stencil:Int):Void {
		
		__context.clearBufferfi (buffer, drawbuffer, depth, stencil);
		
	}
	
	
	public inline function clearBufferfv (buffer:Int, drawbuffer:Int, values:DataPointer):Void {
		
		__context.clearBufferfv (buffer, drawbuffer, values.toFloat32Array ());
		
	}
	
	
	public inline function clearBufferfvWEBGL (buffer:Int, drawbuffer:Int, values:Dynamic, ?srcOffset:Int):Void {
		
		__context.clearBufferfv (buffer, drawbuffer, values, srcOffset);
		
	}
	
	
	public inline function clearBufferiv (buffer:Int, drawbuffer:Int, values:DataPointer):Void {
		
		__context.clearBufferiv (buffer, drawbuffer, values.toInt32Array ());
		
	}
	
	
	public inline function clearBufferivWEBGL (buffer:Int, drawbuffer:Int, values:Dynamic, ?srcOffset:Int):Void {
		
		__context.clearBufferiv (buffer, drawbuffer, values, srcOffset);
		
	}
	
	
	public inline function clearBufferuiv (buffer:Int, drawbuffer:Int, values:DataPointer):Void {
		
		__context.clearBufferuiv (buffer, drawbuffer, values.toUInt32Array ());
		
	}
	
	
	public inline function clearBufferuivWEBGL (buffer:Int, drawbuffer:Int, values:Dynamic, ?srcOffset:Int):Void {
		
		__context.clearBufferuiv (buffer, drawbuffer, values, srcOffset);
		
	}
	
	
	public inline function clearColor (red:Float, green:Float, blue:Float, alpha:Float):Void {
		
		__context.clearColor (red, green, blue, alpha);
		
	}
	
	
	@:dox(hide) @:noCompletion public inline function clearDepth (depth:Float):Void {
		
		__context.clearDepth (depth);
		
	}
	
	
	public inline function clearDepthf (depth:Float):Void {
		
		clearDepth (depth);
		
	}
	
	
	public inline function clearStencil (s:Int):Void {
		
		__context.clearStencil (s);
		
	}
	
	
	//public inline function clientWaitSync (sync:GLSync, flags:Int, timeout:Dynamic /*int64*/):Int {
	//public inline function clientWaitSync (sync:GLSync, flags:Int, timeout:Int64):Int {
	public inline function clientWaitSync (sync:GLSync, flags:Int, timeout:Dynamic):Int {
		
		return __context.clientWaitSync (sync, flags, timeout);
		
	}
	
	
	public inline function copyBufferSubData (readTarget:Int, writeTarget:Int, readOffset:DataPointer, writeOffset:DataPointer, size:Int):Void {
		
		
	}
	
	
	public inline function colorMask (red:Bool, green:Bool, blue:Bool, alpha:Bool):Void {
		
		__context.colorMask (red, green, blue, alpha);
		
	}
	
	
	public inline function compileShader (shader:GLShader):Void {
		
		__context.compileShader (shader);
		
	}
	
	
	public inline function compressedTexImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, imageSize:Int, data:ArrayBufferView):Void {
		
		__context.compressedTexImage2D (target, level, internalformat, width, height, border, data);
		
	}
	
	
	//public function compressedTexImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, srcData:ArrayBufferView):Void {
	//public function compressedTexImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, offset:Int):Void {
	//public function compressedTexImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, srcData:ArrayBufferView, srcOffset:Int = 0, srcLengthOverride:Int = 0):Void {
	public function compressedTexImage2DWEBGL (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, srcData:Dynamic, ?srcOffset:Int, ?srcLengthOverride:Int):Void {
		
		if (srcOffset != null) {
			
			__context.compressedTexImage2D (target, level, internalformat, width, height, border, srcData, srcOffset, srcLengthOverride);
			
		} else {
			
			__context.compressedTexImage2D (target, level, internalformat, width, height, border, srcData);
			
		}
		
	}
	
	
	public inline function compressedTexImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, imageSize:Int, data:DataPointer):Void {
		
		__context.compressedTexImage3D (target, level, internalformat, width, height, depth, border, data.toBufferView (imageSize));
		
	}
	
	
	public inline function compressedTexImage3DWEBGL (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, srcData:Dynamic, ?srcOffset:Int, ?srcLengthOverride:Int):Void {
		
		__context.compressedTexImage3D (target, level, internalformat, width, height, depth, border, srcData, srcOffset, srcLengthOverride);
		
	}
	
	
	public inline function compressedTexSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, imageSize:Int, data:DataPointer):Void {
		
		__context.compressedTexSubImage2D (target, level, xoffset, yoffset, width, height, format, data.toBufferView (imageSize));
		
	}
	
	
	//public function compressedTexSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, srcData:ArrayBufferView):Void {
	//public function compressedTexSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, offset:Int):Void {
	//public function compressedTexSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, srcData:ArrayBufferView, srcOffset:Int = 0, srcLengthOverride:Int = 0):Void {
	public function compressedTexSubImage2DWEBGL (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, srcData:Dynamic, ?srcOffset:Int, ?srcLengthOverride:Int):Void {
		
		if (srcOffset != null) {
			
			__context.compressedTexSubImage2D (target, level, xoffset, yoffset, width, height, format, srcData, srcOffset, srcLengthOverride);
			
		} else {
			
			__context.compressedTexSubImage2D (target, level, xoffset, yoffset, width, height, format, srcData);
			
		}
		
	}
	
	
	public inline function compressedTexSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, imageSize:Int, data:DataPointer):Void {
		
		__context.compressedTexSubImage3D (target, level, xoffset, yoffset, zoffset, width, height, depth, format, data.toBufferView (imageSize));
		
	}
	
	
	public inline function compressedTexSubImage3DWEBGL (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, srcData:ArrayBufferView, ?srcOffset:Int, ?srcLengthOverride:Int):Void {
		
		__context.compressedTexSubImage3D (target, level, xoffset, yoffset, zoffset, width, height, depth, format, srcData, srcOffset, srcLengthOverride);
		
	}
	
	
	public inline function copyTexImage2D (target:Int, level:Int, internalformat:Int, x:Int, y:Int, width:Int, height:Int, border:Int):Void {
		
		__context.copyTexImage2D (target, level, internalformat, x, y, width, height, border);
		
	}
	 
	
	public inline function copyTexSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, x:Int, y:Int, width:Int, height:Int):Void {
		
		__context.copyTexSubImage2D (target, level, xoffset, yoffset, x, y, width, height);
		
	}
	
	
	public inline function copyTexSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, x:Int, y:Int, width:Int, height:Int):Void {
		
		__context.copyTexSubImage3D (target, level, xoffset, yoffset, zoffset, x, y, width, height);
		
	}
	
	
	public inline function createBuffer ():GLBuffer {
		
		return __context.createBuffer ();
		
	}
	
	
	public inline function createFramebuffer ():GLFramebuffer {
		
		return __context.createFramebuffer ();
		
	}
	
	
	public inline function createProgram ():GLProgram {
		
		return __context.createProgram ();
		
	}
	
	
	public inline function createQuery ():GLQuery {
		
		return __context.createQuery ();
		
	}
	
	
	public inline function createRenderbuffer ():GLRenderbuffer {
		
		return __context.createRenderbuffer ();
		
	}
	
	
	public inline function createSampler ():GLSampler {
		
		return __context.createSampler ();
		
	}
	
	
	public inline function createShader (type:Int):GLShader {
		
		return __context.createShader (type);
		
	}
	
	
	public inline function createTexture ():GLTexture {
		
		return __context.createTexture ();
		
	}
	
	
	public inline function createTransformFeedback ():GLTransformFeedback {
		
		return __context.createTransformFeedback ();
		
	}
	
	
	public inline function createVertexArray ():GLVertexArrayObject {
		
		return __context.createVertexArray ();
		
	}
	
	
	public inline function cullFace (mode:Int):Void {
		
		__context.cullFace (mode);
		
	}
	
	
	public inline function deleteBuffer (buffer:GLBuffer):Void {
		
		__context.deleteBuffer (buffer);
		
	}
	
	
	public inline function deleteFramebuffer (framebuffer:GLFramebuffer):Void {
		
		__context.deleteFramebuffer (framebuffer);
		
	}
	
	
	public inline function deleteProgram (program:GLProgram):Void {
		
		__context.deleteProgram (program);
		
	}
	
	
	public inline function deleteQuery (query:GLQuery):Void {
		
		__context.deleteQuery (query);
		
	}
	
	
	public inline function deleteRenderbuffer (renderbuffer:GLRenderbuffer):Void {
		
		__context.deleteRenderbuffer (renderbuffer);
		
	}
	
	
	public inline function deleteSampler (sampler:GLSampler):Void {
		
		__context.deleteSampler (sampler);
		
	}
	
	
	public inline function deleteShader (shader:GLShader):Void {
		
		__context.deleteShader (shader);
		
	}
	
	
	public inline function deleteSync (sync:GLSync):Void {
		
		__context.deleteSync (sync);
		
	}
	
	
	public inline function deleteTexture (texture:GLTexture):Void {
		
		__context.deleteTexture (texture);
		
	}
	
	
	public inline function deleteTransformFeedback (transformFeedback:GLTransformFeedback):Void {
		
		__context.deleteTransformFeedback (transformFeedback);
		
	}
	
	
	public inline function deleteVertexArray (vertexArray:GLVertexArrayObject):Void {
		
		__context.deleteVertexArray (vertexArray);
		
	}
	
	
	public inline function depthFunc (func:Int):Void {
		
		__context.depthFunc (func);
		
	}
	
	
	public inline function depthMask (flag:Bool):Void {
		
		__context.depthMask (flag);
		
	}
	
	
	@:dox(hide) @:noCompletion public inline function depthRange (zNear:Float, zFar:Float):Void {
		
		__context.depthRange (zNear, zFar);
		
	}
	
	
	public inline function depthRangef (zNear:Float, zFar:Float):Void {
		
		depthRange (zNear, zFar);
		
	}
	
	
	public inline function detachShader (program:GLProgram, shader:GLShader):Void {
		
		__context.detachShader (program, shader);
		
	}
	
	
	public inline function disable (cap:Int):Void {
		
		__context.disable (cap);
		
	}
	
	
	public inline function disableVertexAttribArray (index:Int):Void {
		
		__context.disableVertexAttribArray (index);
		
	}
	
	
	public inline function drawArrays (mode:Int, first:Int, count:Int):Void {
		
		__context.drawArrays (mode, first, count);
		
	}
	
	
	public inline function drawArraysInstanced (mode:Int, first:Int, count:Int, instanceCount:Int):Void {
		
		__context.drawArraysInstanced (mode, first, count, instanceCount);
		
	}
	
	
	public inline function drawBuffers (buffers:Array<Int>):Void {
		
		__context.drawBuffers (buffers);
		
	}
	
	
	public inline function drawElements (mode:Int, count:Int, type:Int, offset:Int):Void {
		
		__context.drawElements (mode, count, type, offset);
		
	}
	
	
	public inline function drawElementsInstanced (mode:Int, count:Int, type:Int, offset:DataPointer, instanceCount:Int):Void {
		
		__context.drawElementsInstanced (mode, count, type, offset.toValue (), instanceCount);
		
	}
	
	
	public inline function drawRangeElements (mode:Int, start:Int, end:Int, count:Int, type:Int, offset:DataPointer):Void {
		
		__context.drawRangeElements (mode, start, end, count, type, offset.toValue ());
		
	}
	
	
	public inline function enable (cap:Int):Void {
		
		__context.enable (cap);
		
	}
	
	
	public inline function enableVertexAttribArray (index:Int):Void {
		
		__context.enableVertexAttribArray (index);
		
	}
	
	
	public inline function endQuery (target:Int):Void {
		
		__context.endQuery (target);
		
	}
	
	
	public inline function endTransformFeedback ():Void {
		
		__context.endTransformFeedback ();
		
	}
	
	
	public inline function fenceSync (condition:Int, flags:Int):GLSync {
		
		return __context.fenceSync (condition, flags);
		
	}
	
	
	public inline function finish ():Void {
		
		__context.finish ();
		
	}
	
	
	public inline function flush ():Void {
		
		__context.flush ();
		
	}
	
	
	public inline function framebufferRenderbuffer (target:Int, attachment:Int, renderbuffertarget:Int, renderbuffer:GLRenderbuffer):Void {
		
		__context.framebufferRenderbuffer (target, attachment, renderbuffertarget, renderbuffer);
		
	}
	
	
	public inline function framebufferTexture2D (target:Int, attachment:Int, textarget:Int, texture:GLTexture, level:Int):Void {
		
		__context.framebufferTexture2D (target, attachment, textarget, texture, level);
		
	}
	
	
	public inline function framebufferTextureLayer (target:Int, attachment:Int, texture:GLTexture, level:Int, layer:Int):Void {
		
		__context.framebufferTextureLayer (target, attachment, texture, level, layer);
		
	}
	
	
	public inline function frontFace (mode:Int):Void {
		
		__context.frontFace (mode);
		
	}
	
	
	public inline function generateMipmap (target:Int):Void {
		
		__context.generateMipmap (target);
		
	}
	
	
	public inline function getActiveAttrib (program:GLProgram, index:Int):GLActiveInfo {
		
		return __context.getActiveAttrib (program, index);
		
	}
	
	
	public inline function getActiveUniform (program:GLProgram, index:Int):GLActiveInfo {
		
		return __context.getActiveUniform (program, index);
		
	}
	
	
	public inline function getActiveUniformBlocki (program:GLProgram, uniformBlockIndex:Int, pname:Int):Dynamic {
		
		return getActiveUniformBlockParameter (program, uniformBlockIndex, pname);
		
	}
	
	
	public function getActiveUniformBlockiv (program:GLProgram, uniformBlockIndex:Int, pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		view[0] = getActiveUniformBlockParameter (program, uniformBlockIndex, pname);
		
	}
	
	
	public inline function getActiveUniformBlockName (program:GLProgram, uniformBlockIndex:Int):String {
		
		return __context.getActiveUniformBlockName (program, uniformBlockIndex);
		
	}
	
	
	public inline function getActiveUniformBlockParameter (program:GLProgram, uniformBlockIndex:Int, pname:Int):Dynamic {
		
		return __context.getActiveUniformBlockParameter (program, uniformBlockIndex, pname);
		
	}
	
	
	public inline function getActiveUniforms (program:GLProgram, uniformIndices:Array<Int>, pname:Int):Dynamic {
		
		return __context.getActiveUniforms (program, uniformIndices, pname);
		
	}
	
	
	public inline function getActiveUniformsiv (program:GLProgram, uniformIndices:Array<Int>, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getAttachedShaders (program:GLProgram):Array<GLShader> {
		
		return __context.getAttachedShaders (program);
		
	}
	
	
	public inline function getAttribLocation (program:GLProgram, name:String):Int {
		
		return __context.getAttribLocation (program, name);
		
	}
	
	
	public inline function getBoolean (pname:Int):Bool {
		
		return getParameter (pname);
		
	}
	
	
	public function getBooleanv (pname:Int, params:DataPointer):Void {
		
		var view = params.toUInt8Array ();
		var result = getParameter (pname);
		
		if (Std.is (result, Array)) {
			
			var data:Array<Bool> = result;
			
			for (i in 0...data.length) {
				
				view[i] = data[i] ? 1 : 0;
				
			}
			
		} else {
			
			view[0] = cast (result, Bool) ? 1 : 0;
			
		}
		
	}
	
	
	public inline function getBufferParameter (target:Int, pname:Int):Dynamic {
		
		return __context.getBufferParameter (target, pname);
		
	}
	
	
	public inline function getBufferParameteri (target:Int, pname:Int):Int {
		
		return getBufferParameter (target, pname);
		
	}
	
	
	public function getBufferParameteri64v (target:Int, pname:Int, params:DataPointer):Void{
		
		
	}
	
	
	public function getBufferParameteriv (target:Int, pname:Int, data:DataPointer):Void {
		
		var view = data.toInt32Array ();
		view[0] = getBufferParameter (target, pname);
		
	}
	
	
	public inline function getBufferPointerv (target:Int, pname:Int):DataPointer {
		
		return 0;
		
	}
	
	
	public inline function getBufferSubData (target:Int, offset:DataPointer, size:Int /*GLsizeiptr*/, data:DataPointer):Void {
		
		__context.getBufferSubData (target, offset.toValue (), data.toBufferView (size));
		
	}
	
	
	//public function getBufferSubData (target:Int, srcByteOffset:DataPointer, dstData:js.html.ArrayBuffer, ?srcOffset:Int, ?length:Int):Void {
	//public function getBufferSubData (target:Int, srcByteOffset:DataPointer, dstData:Dynamic /*SharedArrayBuffer*/, ?srcOffset:Int, ?length:Int):Void {
	public function getBufferSubDataWEBGL (target:Int, srcByteOffset:DataPointer, dstData:Dynamic, ?srcOffset:Int, ?length:Int):Void {
		
		if (srcOffset != null) {
			
			__context.getBufferSubData (target, srcByteOffset, dstData, srcOffset, length);
			
		} else {
			
			__context.getBufferSubData (target, srcByteOffset, dstData);
			
		}
		
	}
	
	
	public inline function getContextAttributes ():GLContextAttributes {
		
		return __context.getContextAttributes ();
		
	}
	
	
	public inline function getError ():Int {
		
		return __context.getError ();
		
	}
	
	
	public inline function getExtension (name:String):Dynamic {
		
		return __context.getExtension (name);
		
	}
	
	
	public inline function getFloat (pname:Int):Float {
		
		return getParameter (pname);
		
	}
	
	
	public function getFloatv (pname:Int, params:DataPointer):Void {
		
		var view = params.toFloat32Array ();
		
		var result = getParameter (pname);
		
		if (Std.is (result, ArrayBufferView)) {
			
			var data:Float32Array = result;
			
			for (i in 0...data.length) {
				
				view[i] = data[i];
				
			}
			
		} else {
			
			view[0] = cast (result, Float);
			
		}
		
	}
	
	
	public inline function getFragDataLocation (program:GLProgram, name:String):Int {
		
		return __context.getFragDataLocation (program, name);
		
	}
	
	
	public inline function getFramebufferAttachmentParameter (target:Int, attachment:Int, pname:Int):Dynamic {
		
		return __context.getFramebufferAttachmentParameter (target, attachment, pname);
		
	}
	
	
	public inline function getFramebufferAttachmentParameteri (target:Int, attachment:Int, pname:Int):Dynamic {
		
		return getFramebufferAttachmentParameter (target, attachment, pname);
		
	}
	
	
	public function getFramebufferAttachmentParameteriv (target:Int, attachment:Int, pname:Int, params:DataPointer):Void {
		
		var value = getFramebufferAttachmentParameteri (target, attachment, pname);
		
		var view = params.toInt32Array ();
		view[0] = value;
		
	}
	
	
	public inline function getIndexedParameter (target:Int, index:Int):Dynamic {
		
		return __context.getIndexedParameter (target, index);
		
	}
	
	
	public inline function getInteger (pname:Int):Int {
		
		return getParameter (pname);
		
	}
	
	
	public inline function getInteger64 (pname:Int):Int64 {
		
		return Int64.ofInt (0);
		
	}
	
	
	public inline function getInteger64i (pname:Int):Int64 {
		
		return Int64.ofInt (0);
		
	}
	
	
	public inline function getInteger64i_v (pname:Int, index:Int, params:DataPointer):Void {
		
		
	}
	
	
	public function getInteger64v (pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getIntegeri (pname:Int):Int {
		
		return 0;
		
	}
	
	
	public inline function getIntegeri_v (pname:Int, index:Int, params:DataPointer):Void {
		
		
	}
	
	
	public function getIntegerv (pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		var result = getParameter (pname);
		
		if (Std.is (result, ArrayBufferView)) {
			
			var data:Int32Array = result;
			
			for (i in 0...data.length) {
				
				view[i] = data[i];
				
			}
			
		} else {
			
			view[0] = cast (result, Int);
			
		}
		
	}
	
	
	public inline function getInternalformati (target:Int, internalformat:Int, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public function getInternalformativ (target:Int, internalformat:Int, pname:Int, bufSize:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getInternalformatParameter (target:Int, internalformat:Int, pname:Int):Dynamic {
		
		return __context.getInternalformatParameter (target, internalformat, pname);
		
	}
	
	
	public inline function getParameter (pname:Int):Dynamic {
		
		return __context.getParameter (pname);
		
	}
	
	
	public inline function getProgramBinary (program:GLProgram, binaryFormat:Int):Bytes {
		
		return null;
		
	}
	
	
	public inline function getProgrami (program:GLProgram, pname:Int):Int {
		
		return getProgramParameter (program, pname);
		
	}
	
	
	public function getProgramiv (program:GLProgram, pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		view[0] = getProgramParameter (program, pname);
		
	}
	
	
	public inline function getProgramInfoLog (program:GLProgram):String {
		
		return __context.getProgramInfoLog (program);
		
	}
	
	
	public inline function getProgramParameter (program:GLProgram, pname:Int):Dynamic {
		
		return __context.getProgramParameter (program, pname);
		
	}
	
	
	public inline function getQuery (target:Int, pname:Int):GLQuery {
		
		return __context.getQuery (target, pname);
		
	}
	
	
	public inline function getQueryi (target:Int, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public function getQueryiv (target:Int, pname:Int, params:DataPointer):Void {
		
		
		
	}
	
	
	public inline function getQueryObjectui (query:GLQuery, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public function getQueryObjectuiv (query:GLQuery, pname:Int, params:DataPointer):Void {
		
		
		
	}
	
	
	public inline function getQueryParameter (query:GLQuery, pname:Int):Dynamic {
		
		return __context.getQueryParameter (query, pname);
		
	}
	
	
	public inline function getRenderbufferParameter (target:Int, pname:Int):Dynamic {
		
		return __context.getRenderbufferParameter (target, pname);
		
	}
	
	
	public inline function getRenderbufferParameteri (target:Int, pname:Int):Int {
		
		return getRenderbufferParameter (target, pname);
		
	}
	
	
	public function getRenderbufferParameteriv (target:Int, pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		view[0] = getRenderbufferParameter (target, pname);
		
	}
	
	
	public inline function getSamplerParameter (sampler:GLSampler, pname:Int):Dynamic {
		
		return __context.getSamplerParameter (sampler, pname);
		
	}
	
	
	public inline function getSamplerParameterf (sampler:GLSampler, pname:Int):Float {
		
		return 0;
		
	}
	
	
	public function getSamplerParameterfv (sampler:GLSampler, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getSamplerParameteri (sampler:GLSampler, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public function getSamplerParameteriv (sampler:GLSampler, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getShaderi (shader:GLShader, pname:Int):Int {
		
		return getShaderParameter (shader, pname);
		
	}
	
	
	public function getShaderiv (shader:GLShader, pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		view[0] = getShaderParameter (shader, pname);
		
	}
	
	
	public inline function getShaderInfoLog (shader:GLShader):String {
		
		return __context.getShaderInfoLog (shader);
		
	}
	
	
	public inline function getShaderParameter (shader:GLShader, pname:Int):Dynamic {
		
		return __context.getShaderParameter (shader, pname);
		
	}
	
	
	public inline function getShaderPrecisionFormat (shadertype:Int, precisiontype:Int):GLShaderPrecisionFormat {
		
		return __context.getShaderPrecisionFormat (shadertype, precisiontype);
		
	}
	
	
	public inline function getShaderSource (shader:GLShader):String {
		
		return __context.getShaderSource (shader);
		
	}
	
	
	public function getString (pname:Int):String {
		
		if (pname == GL.EXTENSIONS) {
			
			return getSupportedExtensions ().join (" ");
			
		} else {
			
			return getParameter (pname);
			
		}
		
	}
	
	
	public inline function getStringi (name:Int, index:Int):String {
		
		return null;
		
	}
	
	
	public inline function getSupportedExtensions ():Array<String> {
		
		return __context.getSupportedExtensions ();
		
	}
	
	
	public inline function getSyncParameter (sync:GLSync, pname:Int):Dynamic {
		
		return __context.getSyncParameter (sync, pname);
		
	}
	
	
	public inline function getSyncParameteri (sync:GLSync, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public function getSyncParameteriv (sync:GLSync, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getTexParameter (target:Int, pname:Int):Dynamic {
		
		return __context.getTexParameter (target, pname);
		
	}
	
	
	public inline function getTexParameterf (target:Int, pname:Int):Float {
		
		return getTexParameter (target, pname);
		
	}
	
	
	public function getTexParameterfv (target:Int, pname:Int, params:DataPointer):Void {
		
		var view = params.toFloat32Array ();
		view[0] = getTexParameter (target, pname);
		
	}
	
	
	public inline function getTexParameteri (target:Int, pname:Int):Int {
		
		return getTexParameter (target, pname);
		
	}
	
	
	public function getTexParameteriv (target:Int, pname:Int, params:DataPointer):Void {
		
		var view = params.toInt32Array ();
		view[0] = getTexParameter (target, pname);
		
	}
	
	
	public inline function getTransformFeedbackVarying (program:GLProgram, index:Int):GLActiveInfo {
		
		return __context.getTransformFeedbackVarying (program, index);
		
	}
	
	
	public inline function getUniform (program:GLProgram, location:GLUniformLocation):Dynamic {
		
		return __context.getUniform (program, location);
		
	}
	
	
	public inline function getUniformf (program:GLProgram, location:GLUniformLocation):Float {
		
		return getUniform (program, location);
		
	}
	
	
	public function getUniformfv (program:GLProgram, location:GLUniformLocation, params:DataPointer):Void {
		
		var view = params.toFloat32Array ();
		view[0] = getUniformf (program, location);
		
	}
	
	
	public inline function getUniformi (program:GLProgram, location:GLUniformLocation):Dynamic {
		
		return getUniform (program, location);
		
	}
	
	
	public function getUniformiv (program:GLProgram, location:GLUniformLocation, params:DataPointer):Void {
		
		var value = getUniformi (program, location);
		
		var view = params.toInt32Array ();
		view[0] = value;
		
	}
	
	
	public inline function getUniformui (program:GLProgram, location:GLUniformLocation):Int {
		
		return 0;
		
	}
	
	
	public function getUniformuiv (program:GLProgram, location:GLUniformLocation, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getUniformBlockIndex (program:GLProgram, uniformBlockName:String):Int {
		
		return __context.getUniformBlockIndex (program, uniformBlockName);
		
	}
	
	
	//public inline function getUniformIndices (program:GLProgram, uniformNames:String):Array<Int> {
	//public inline function getUniformIndices (program:GLProgram, uniformNames:Array<String>):Array<Int> {
	public inline function getUniformIndices (program:GLProgram, uniformNames:Dynamic):Array<Int> {
		
		return __context.getUniformIndices (program, uniformNames);
		
	}
	
	
	public inline function getUniformLocation (program:GLProgram, name:String):GLUniformLocation {
		
		return __context.getUniformLocation (program, name);
		
	}
	
	
	public inline function getVertexAttrib (index:Int, pname:Int):Dynamic {
		
		return __context.getVertexAttrib (index, pname);
		
	}
	
	
	public inline function getVertexAttribf (index:Int, pname:Int):Float {
		
		return 0;
		
	}
	
	
	public function getVertexAttribfv (index:Int, pname:Int, params:DataPointer):Void {
		
		
		
	}
	
	
	public inline function getVertexAttribi (index:Int, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public inline function getVertexAttribIi (index:Int, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public inline function getVertexAttribIiv (index:Int, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public inline function getVertexAttribIui (index:Int, pname:Int):Int {
		
		return 0;
		
	}
	
	
	public inline function getVertexAttribIuiv (index:Int, pname:Int, params:DataPointer):Void {
		
		
	}
	
	
	public function getVertexAttribiv (index:Int, pname:Int, params:DataPointer):Void {
		
		
		
	}
	
	
	@:dox(hide) @:noCompletion public inline function getVertexAttribOffset (index:Int, pname:Int):DataPointer {
		
		return __context.getVertexAttribOffset (index, pname);
		
	}
	
	
	public inline function getVertexAttribPointerv (index:Int, pname:Int):DataPointer {
		
		return getVertexAttribOffset (index, pname);
		
	}
	
	
	public inline function hint (target:Int, mode:Int):Void {
		
		__context.hint (target, mode);
		
	}
	
	
	public inline function invalidateFramebuffer (target:Int, attachments:Array<Int>):Void {
		
		__context.invalidateFramebuffer (target, attachments);
		
	}
	
	
	public inline function invalidateSubFramebuffer (target:Int, attachments:Array<Int>, x:Int, y:Int, width:Int, height:Int):Void {
		
		__context.invalidateSubFramebuffer (target, attachments, x, y, width, height);
		
	}
	
	
	public inline function isBuffer (buffer:GLBuffer):Bool {
		
		return __context.isBuffer (buffer);
		
	}
	
	
	public inline function isContextLost ():Bool {
		
		return __contextLost || __context.isContextLost ();
		
	}
	
	
	public inline function isEnabled (cap:Int):Bool {
		
		return __context.isEnabled (cap);
		
	}
	
	
	public inline function isFramebuffer (framebuffer:GLFramebuffer):Bool {
		
		return __context.isFramebuffer (framebuffer);
		
	}
	
	
	public inline function isProgram (program:GLProgram):Bool {
		
		return __context.isProgram (program);
		
	}
	
	
	public inline function isQuery (query:GLQuery):Bool {
		
		return __context.isQuery (query);
		
	}
	
	
	public inline function isRenderbuffer (renderbuffer:GLRenderbuffer):Bool {
		
		return __context.isRenderbuffer (renderbuffer);
		
	}
	
	
	public inline function isSampler (sampler:GLSampler):Bool {
		
		return __context.isSampler (sampler);
		
	}
	
	
	public inline function isShader (shader:GLShader):Bool {
		
		return __context.isShader (shader);
		
	}
	
	
	public inline function isSync (sync:GLSync):Bool {
		
		return __context.isSync (sync);
		
	}
	
	
	public inline function isTexture (texture:GLTexture):Bool {
		
		return __context.isTexture (texture);
		
	}
	
	
	public inline function isTransformFeedback (transformFeedback:GLTransformFeedback):Bool {
		
		return __context.isTransformFeedback (transformFeedback);
		
	}
	
	
	public inline function isVertexArray (vertexArray:GLVertexArrayObject):Bool {
		
		return __context.isVertexArray (vertexArray);
		
	}
	
	
	public inline function lineWidth (width:Float):Void {
		
		__context.lineWidth (width);
		
	}
	
	
	public inline function linkProgram (program:GLProgram):Void {
		
		__context.linkProgram (program);
		
	}
	
	
	public inline function mapBufferRange (target:Int, offset:DataPointer, length:Int, access:Int):DataPointer {
		
		return 0;
		
	}
	
	
	public inline function pauseTransformFeedback ():Void {
		
		__context.pauseTransformFeedback ();
		
	}
	
	
	public inline function pixelStorei (pname:Int, param:Int):Void {
		
		__context.pixelStorei (pname, param);
		
	}
	
	
	public inline function polygonOffset (factor:Float, units:Float):Void {
		
		__context.polygonOffset (factor, units);
		
	}
	
	
	public inline function programBinary (program:GLProgram, binaryFormat:Int, binary:DataPointer, length:Int):Void {
		
		
		
	}
	
	
	public inline function programParameteri (program:GLProgram, pname:Int, value:Int):Void {
		
		
		
	}
	
	
	public inline function readBuffer (src:Int):Void {
		
		__context.readBuffer (src);
		
	}
	
	
	public inline function readPixels (x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, pixels:DataPointer):Void {
		
		__context.readPixels (x, y, width, height, format, type, pixels.toBufferView ());
		
	}
	
	
	//public function readPixels (x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, pixels:ArrayBufferView):Void {
	//public function readPixels (x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, pixels:ArrayBufferView, ?dstOffset:Int):Void {
	public function readPixelsWEBGL (x:Int, y:Int, width:Int, height:Int, format:Int, type:Int, pixels:ArrayBufferView, ?dstOffset:Int):Void {
		
		if (dstOffset != null) {
			
			__context.readPixels (x, y, width, height, format, type, pixels, dstOffset);
			
		} else {
			
			__context.readPixels (x, y, width, height, format, type, pixels);
			
		}
		
	}
	
	
	public inline function releaseShaderCompiler ():Void {
		
		
		
	}
	
	
	public inline function renderbufferStorage (target:Int, internalformat:Int, width:Int, height:Int):Void {
		
		__context.renderbufferStorage (target, internalformat, width, height);
		
	}
	
	
	public inline function renderbufferStorageMultisample (target:Int, samples:Int, internalFormat:Int, width:Int, height:Int):Void {
		
		__context.renderbufferStorageMultisample (target, samples, internalFormat, width, height);
		
	}
	
	
	public inline function resumeTransformFeedback ():Void {
		
		__context.resumeTransformFeedback ();
		
	}
	
	
	public inline function sampleCoverage (value:Float, invert:Bool):Void {
		
		__context.sampleCoverage (value, invert);
		
	}
	
	
	public inline function samplerParameterf (sampler:GLSampler, pname:Int, param:Float):Void {
		
		__context.samplerParameterf (sampler, pname, param);
		
	}
	
	
	public inline function samplerParameteri (sampler:GLSampler, pname:Int, param:Int):Void {
		
		__context.samplerParameteri (sampler, pname, param);
		
	}
	
	
	public inline function scissor (x:Int, y:Int, width:Int, height:Int):Void {
		
		__context.scissor (x, y, width, height);
		
	}
	
	
	public inline function shaderBinary (shaders:Array<GLShader>, binaryformat:Int, binary:DataPointer, length:Int):Void {
		
		
		
	}
	
	
	public inline function shaderSource (shader:GLShader, source:String):Void {
		
		__context.shaderSource (shader, source);
		
	}
	
	
	public inline function stencilFunc (func:Int, ref:Int, mask:Int):Void {
		
		__context.stencilFunc (func, ref, mask);
		
	}
	
	
	public inline function stencilFuncSeparate (face:Int, func:Int, ref:Int, mask:Int):Void {
		
		__context.stencilFuncSeparate (face, func, ref, mask);
		
	}
	
	
	public inline function stencilMask (mask:Int):Void {
		
		__context.stencilMask (mask);
		
	}
	
	
	public inline function stencilMaskSeparate (face:Int, mask:Int):Void {
		
		__context.stencilMaskSeparate (face, mask);
		
	}
	
	
	public inline function stencilOp (fail:Int, zfail:Int, zpass:Int):Void {
		
		__context.stencilOp (fail, zfail, zpass);
		
	}
	
	
	public inline function stencilOpSeparate (face:Int, fail:Int, zfail:Int, zpass:Int):Void {
		
		__context.stencilOpSeparate (face, fail, zfail, zpass);
		
	}
	
	
	public inline function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, data:ArrayBufferView):Void {
		
		__context.texImage2D (target, level, internalformat, width, height, border, format, type, data);
		
	}
	
	
	//public function texImage2D (target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:Dynamic /*ImageBitmap*/):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:#if (js && html5) CanvasElement #else Dynamic #end):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:#if (js && html5) ImageData #else Dynamic #end):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:#if (js && html5) ImageElement #else Dynamic #end):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, format:Int, type:Int, pixels:#if (js && html5) VideoElement #else Dynamic #end):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:ArrayBufferView):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:CanvasElement):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:Dynamic /*ImageBitmap*/):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:ImageData):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:ImageElement):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, offset:DataPointer):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, pixels:VideoElement):Void {
	//public function texImage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Int, format:Int, type:Int, srcData:ArrayBufferView, srcOffset:Int):Void {
	public function texImage2DWEBGL (target:Int, level:Int, internalformat:Int, width:Int, height:Int, border:Dynamic, ?format:Int, ?type:Int, ?srcData:Dynamic, ?srcOffset:Int):Void {
		
		if (srcOffset != null) {
			
			__context.texImage2D (target, level, internalformat, width, height, border, format, type, srcData, srcOffset);
			
		} else if (format != null) {
			
			__context.texImage2D (target, level, internalformat, width, height, border, format, type, srcData);
			
		} else {
			
			__context.texImage2D (target, level, internalformat, width, height, border); // target, level, internalformat, format, type, pixels
			
		}
		
	}
	
	
	public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, data:DataPointer):Void {
		
		__context.texImage3D (target, level, internalformat, width, height, depth, border, format, type, data.toBufferView ());
		
	}
	
	
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, source:js.html.CanvasElement):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, source:js.html.ImageElement):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, source:js.html.VideoElement):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, source:Dynamic /*js.html.ImageBitmap*/):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, source:js.html.ImageData):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, offset:DataPointer):Void {
	//public inline function texImage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, srcData:js.html.ArrayBufferView, ?srcOffset:Int):Void {
	public inline function texImage3DWEBGL (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int, border:Int, format:Int, type:Int, srcData:Dynamic, ?srcOffset:Int):Void {
		
		__context.texImage3D (target, level, internalformat, width, height, depth, border, format, type, srcData, srcOffset);
		
	}
	
	
	public inline function texStorage2D (target:Int, level:Int, internalformat:Int, width:Int, height:Int):Void {
		
		__context.texStorage2D (target, level, internalformat, width, height);
		
	}
	
	
	public inline function texStorage3D (target:Int, level:Int, internalformat:Int, width:Int, height:Int, depth:Int):Void {
		
		__context.texStorage3D (target, level, internalformat, width, height, depth);
		
	}
	
	
	public inline function texParameterf (target:Int, pname:Int, param:Float):Void {
		
		__context.texParameterf (target, pname, param);
		
	}
	
	
	public inline function texParameteri (target:Int, pname:Int, param:Int):Void {
		
		__context.texParameteri (target, pname, param);
		
	}
	
	
	public inline function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, data:DataPointer):Void {
		
		__context.texSubImage2D (target, level, xoffset, yoffset, width, height, format, type, data.toBufferView ());
		
	}
	
	
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:#if (js && html5) CanvasElement #else Dynamic #end):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:Dynamic /*ImageBitmap*/):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:#if (js && html5) ImageData #else Dynamic #end):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:#if (js && html5) ImageElement #else Dynamic #end):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, format:Int, type:Int, pixels:#if (js && html5) VideoElement #else Dynamic #end):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:ArrayBufferView):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:CanvasElement):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:Dynamic /*ImageBitmap*/):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:ImageData):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:ImageElement):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, offset:DataPointer):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, pixels:VideoElement):Void {
	//public function texSubImage2D (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Int, type:Int, srcData:ArrayBufferView, srcOffset:Int):Void {
	public function texSubImage2DWEBGL (target:Int, level:Int, xoffset:Int, yoffset:Int, width:Int, height:Int, format:Dynamic, ?type:Int, ?srcData:Dynamic, ?srcOffset:Int):Void {
		
		if (srcOffset != null) {
			
			__context.texSubImage2D (target, level, xoffset, yoffset, width, height, format, type, srcData, srcOffset);
			
		} else if (type != null) {
			
			__context.texSubImage2D (target, level, xoffset, yoffset, width, height, format, type, srcData);
			
		} else {
			
			__context.texSubImage2D (target, level, xoffset, yoffset, width, height, format); // target, level, xoffset, yoffset, format, type, pixels
			
		}
		
	}
	
	
	public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, data:DataPointer):Void {
		
		__context.texSubImage3D (target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, data.toBufferView ());
		
	}
	
	
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, offset:DataPointer):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:js.html.ImageData):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:js.html.ImageElement):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:js.html.CanvasElement):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:js.html.VideoElement):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:Dynamic /*ImageBitmap*/):Void {
	//public inline function texSubImage3D (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, pixels:js.html.ArrayBufferView):Void {
	public inline function texSubImage3DWEBGL (target:Int, level:Int, xoffset:Int, yoffset:Int, zoffset:Int, width:Int, height:Int, depth:Int, format:Int, type:Int, source:Dynamic, ?srcOffset:Int):Void {
		
		__context.texSubImage3D (target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, source, srcOffset);
		
	}
	
	
	public inline function transformFeedbackVaryings (program:GLProgram, varyings:Array<String>, bufferMode:Int):Void {
		
		__context.transformFeedbackVaryings (program, varyings, bufferMode);
		
	}
	
	
	public inline function uniform1f (location:GLUniformLocation, v0:Float):Void {
		
		__context.uniform1f (location, v0);
		
	}
	
	
	public inline function uniform1fv (location:GLUniformLocation, count:Int, v:Float32Array):Void {
		
		__context.uniform1fv (location, v);
		
	}
	
	
	//public function uniform1fv (location:GLUniformLocation, data:Float32Array):Void {
	//public function uniform1fv (location:GLUniformLocation, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform1fv (location:GLUniformLocation, data:Array<Float>):Void {
	public function uniform1fvWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform1fv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform1fv (location, data);
			
		}
		
	}
	
	
	public inline function uniform1i (location:GLUniformLocation, v0:Int):Void {
		
		__context.uniform1i (location, v0);
		
	}
	
	
	public inline function uniform1iv (location:GLUniformLocation, count:Int, v:Int32Array):Void {
		
		__context.uniform1iv (location, v);
		
	}
	
	
	//public function uniform1iv (location:GLUniformLocation, data:Int32Array):Void {
	//public function uniform1iv (location:GLUniformLocation, data:Int32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform1iv (location:GLUniformLocation, data:Array<Int>):Void {
	public function uniform1ivWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform1iv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform1iv (location, data);
			
		}
		
	}
	
	
	public inline function uniform1ui (location:GLUniformLocation, v0:Int):Void {
		
		return __context.uniform1ui (location, v0);
		
	}
	
	
	public inline function uniform1uiv (location:GLUniformLocation, count:Int, v:UInt32Array):Void {
		
		__context.uniform1uiv (location, v);
		
	}
	
	
	public inline function uniform1uivWEBGL (location:GLUniformLocation, data:UInt32Array, ?srcOffset:Dynamic, ?srcLength:Int):Void {
		
		__context.uniform1uiv (location, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniform2f (location:GLUniformLocation, v0:Float, v1:Float):Void {
		
		__context.uniform2f (location, v0, v1);
		
	}
	
	
	public inline function uniform2fv (location:GLUniformLocation, count:Int, v:Float32Array):Void {
		
		__context.uniform2fv (location, v);
		
	}
	
	
	//public function uniform2fv (location:GLUniformLocation, data:Float32Array):Void {
	//public function uniform2fv (location:GLUniformLocation, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform2fv (location:GLUniformLocation, data:Array<Float>):Void {
	public function uniform2fvWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform2fv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform2fv (location, data);
			
		}
		
	}
	
	
	public inline function uniform2i (location:GLUniformLocation, x:Int, y:Int):Void {
		
		__context.uniform2i (location, x, y);
		
	}
	
	
	public inline function uniform2iv (location:GLUniformLocation, count:Int, v:Int32Array):Void {
		
		__context.uniform2iv (location, v);
		
	}
	
	
	//public function uniform2iv (location:GLUniformLocation, data:Int32Array):Void {
	//public function uniform2iv (location:GLUniformLocation, data:Int32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform2iv (location:GLUniformLocation, data:Array<Int>):Void {
	public function uniform2ivWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform2iv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform2iv (location, data);
			
		}
		
	}
	
	
	public inline function uniform2ui (location:GLUniformLocation, v0:Int, v1:Int):Void {
		
		__context.uniform2ui (location, v0, v1);
		
	}
	
	
	public inline function uniform2uiv (location:GLUniformLocation, count:Int, v:UInt32Array):Void {
		
		__context.uniform2uiv (location, v);
		
	}
	
	
	public inline function uniform2uivWEBGL (location:GLUniformLocation, data:UInt32Array, ?srcOffset:Dynamic, ?srcLength:Int):Void {
		
		__context.uniform2uiv (location, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniform3f (location:GLUniformLocation, v0:Float, v1:Float, v2:Float):Void {
		
		__context.uniform3f (location, v0, v1, v2);
		
	}
	
	
	public inline function uniform3fv (location:GLUniformLocation, count:Int, v:Float32Array):Void {
		
		__context.uniform3fv (location, v);
		
	}
	
	
	//public function uniform3fv (location:GLUniformLocation, data:Float32Array):Void {
	//public function uniform3fv (location:GLUniformLocation, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform3fv (location:GLUniformLocation, data:Array<Float>):Void {
	public function uniform3fvWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform3fv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform3fv (location, data);
			
		}
		
	}
	
	
	public inline function uniform3i (location:GLUniformLocation, x:Int, y:Int, z:Int):Void {
		
		__context.uniform3i (location, x, y, z);
		
	}
	
	
	public inline function uniform3iv (location:GLUniformLocation, count:Int, v:Int32Array):Void {
		
		__context.uniform3iv (location, v);
		
	}
	
	
	//public function uniform3iv (location:GLUniformLocation, data:Int32Array):Void {
	//public function uniform3iv (location:GLUniformLocation, data:Int32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform3iv (location:GLUniformLocation, data:Array<Int>):Void {
	public function uniform3ivWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform3iv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform3iv (location, data);
			
		}
		
	}
	
	
	public inline function uniform3ui (location:GLUniformLocation, v0:Int, v1:Int, v2:Int):Void {
		
		__context.uniform3ui (location, v0, v1, v2);
		
	}
	
	
	public inline function uniform3uiv (location:GLUniformLocation, count:Int, v:UInt32Array):Void {
		
		__context.uniform3uiv (location, v);
		
	}
	
	
	public inline function uniform3uivWEBGL (location:GLUniformLocation, data:UInt32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniform3uiv (location, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniform4f (location:GLUniformLocation, v0:Float, v1:Float, v2:Float, v3:Float):Void {
		
		__context.uniform4f (location, v0, v1, v2, v3);
		
	}
	
	
	public inline function uniform4fv (location:GLUniformLocation, count:Int, v:Float32Array):Void {
		
		__context.uniform4fv (location, v);
		
	}
	
	
	//public function uniform4fv (location:GLUniformLocation, data:Float32Array):Void {
	//public function uniform4fv (location:GLUniformLocation, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform4fv (location:GLUniformLocation, data:Array<Float>):Void {
	public function uniform4fvWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform4fv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform4fv (location, data);
			
		}
		
	}
	
	
	public inline function uniform4i (location:GLUniformLocation, v0:Int, v1:Int, v2:Int, v3:Int):Void {
		
		__context.uniform4i (location, v0, v1, v2, v3);
		
	}
	
	
	public inline function uniform4iv (location:GLUniformLocation, count:Int, v:Int32Array):Void {
		
		__context.uniform4iv (location, v);
		
	}
	
	
	//public function uniform4iv (location:GLUniformLocation, data:Int32Array):Void {
	//public function uniform4iv (location:GLUniformLocation, data:Int32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniform4iv (location:GLUniformLocation, data:Array<Int>):Void {
	public function uniform4ivWEBGL (location:GLUniformLocation, data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniform4iv (location, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniform4iv (location, data);
			
		}
		
	}
	
	
	public inline function uniform4ui (location:GLUniformLocation, v0:Int, v1:Int, v2:Int, v3:Int):Void {
		
		__context.uniform4ui (location, v0, v1, v2, v3);
		
	}
	
	
	public inline function uniform4uiv (location:GLUniformLocation, count:Int, v:UInt32Array):Void {
		
		__context.uniform4uiv (location, v);
		
	}
	
	
	public inline function uniform4uivWEBGL (location:GLUniformLocation, data:UInt32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniform4uiv (location, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniformBlockBinding (program:GLProgram, uniformBlockIndex:Int, uniformBlockBinding:Int):Void {
		
		__context.uniformBlockBinding (program, uniformBlockIndex, uniformBlockBinding);
		
	}
	
	
	public inline function uniformMatrix2fv (location:GLUniformLocation, count:Int, transpose:Bool, v:Float32Array):Void {
		
		__context.uniformMatrix2fv (location, transpose, v);
		
	}
	
	
	//public function uniformMatrix2fv (location:GLUniformLocation, transpose:Bool, data:Float32Array):Void {
	//public function uniformMatrix2fv (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniformMatrix2fv (location:GLUniformLocation, transpose:Bool, data:Array<Float>):Void {
	public function uniformMatrix2fvWEBGL (location:GLUniformLocation, transpose:Bool, ?data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniformMatrix2fv (location, transpose, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniformMatrix2fv (location, transpose, data);
			
		}
		
	}
	
	
	public inline function uniformMatrix2x3fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix2x3fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 6));
		
	}
	
	
	public inline function uniformMatrix2x3fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniformMatrix2x3fv (location, transpose, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniformMatrix2x4fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix2x4fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 8));
		
	}
	
	
	public inline function uniformMatrix2x4fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniformMatrix2x4fv (location, transpose, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniformMatrix3fv (location:GLUniformLocation, count:Int, transpose:Bool, v:Float32Array):Void {
		
		__context.uniformMatrix3fv (location, transpose, v);
		
	}
	
	
	//public function uniformMatrix3fv (location:GLUniformLocation, transpose:Bool, data:Float32Array):Void {
	//public function uniformMatrix3fv (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniformMatrix3fv (location:GLUniformLocation, transpose:Bool, data:Array<Float>):Void {
	public function uniformMatrix3fvWEBGL (location:GLUniformLocation, transpose:Bool, ?data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniformMatrix3fv (location, transpose, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniformMatrix3fv (location, transpose, data);
			
		}
		
	}
	
	
	public inline function uniformMatrix3x2fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix3x2fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 6));
		
	}
	
	
	public inline function uniformMatrix3x2fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniformMatrix3x2fv (location, transpose, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniformMatrix3x4fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix3x4fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 12));
		
	}
	
	
	public inline function uniformMatrix3x4fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniformMatrix3x4fv (location, transpose, data, srcOffset, srcLength);
		
	}
	
	
	public inline function uniformMatrix4fv (location:GLUniformLocation, count:Int, transpose:Bool, v:Float32Array):Void {
		
		__context.uniformMatrix4fv (location, transpose, v);
		
	}
	
	
	//public function uniformMatrix4fv (location:GLUniformLocation, transpose:Bool, data:Float32Array):Void {
	//public function uniformMatrix4fv (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
	//public function uniformMatrix4fv (location:GLUniformLocation, transpose:Bool, data:Array<Float>):Void {
	public function uniformMatrix4fvWEBGL (location:GLUniformLocation, transpose:Bool, ?data:Dynamic, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniformMatrix4fv (location, transpose, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniformMatrix4fv (location, transpose, data);
			
		}
		
	}
	
	
	public inline function uniformMatrix4x2fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix4x2fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 8));
		
	}
	
	
	public function uniformMatrix4x2fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		if (srcOffset != null) {
			
			__context.uniformMatrix4x2fv (location, transpose, data, srcOffset, srcLength);
			
		} else {
			
			__context.uniformMatrix4x2fv (location, transpose, data);
			
		}
		
	}
	
	
	public inline function uniformMatrix4x3fv (location:GLUniformLocation, count:Int, transpose:Bool, v:DataPointer):Void {
		
		__context.uniformMatrix4x3fv (location, transpose, v.toFloat32Array (count * Float32Array.BYTES_PER_ELEMENT * 12));
		
	}
	
	
	public inline function uniformMatrix4x3fvWEBGL (location:GLUniformLocation, transpose:Bool, data:Float32Array, ?srcOffset:Int, ?srcLength:Int):Void {
		
		__context.uniformMatrix4x3fv (location, transpose, data, srcOffset, srcLength);
		
	}
	
	
	public inline function unmapBuffer (target:Int):Bool {
		
		return false;
		
	}
	
	
	public inline function useProgram (program:GLProgram):Void {
		
		__context.useProgram (program);
		
	}
	
	
	public inline function validateProgram (program:GLProgram):Void {
		
		__context.validateProgram (program);
		
	}
	
	
	public inline function vertexAttrib1f (index:Int, v0:Float):Void {
		
		__context.vertexAttrib1f (index, v0);
		
	}
	
	
	public inline function vertexAttrib1fv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttrib1fv (index, v.toFloat32Array ());
		
	}
	
	
	//public function vertexAttrib1fv (index:Int, v:Float32Array):Void {
	//public function vertexAttrib1fv (index:Int, v:Array<Float>):Void {
	public inline function vertexAttrib1fvWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttrib1fv (index, v);
		
	}
	
	
	public inline function vertexAttrib2f (index:Int, v0:Float, v1:Float):Void {
		
		__context.vertexAttrib2f (index, v0, v1);
		
	}
	
	
	public inline function vertexAttrib2fv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttrib2fv (index, v.toFloat32Array ());
		
	}
	
	
	//public function vertexAttrib2fv (index:Int, v:Float32Array):Void {
	//public function vertexAttrib2fv (index:Int, v:Array<Float>):Void {
	public inline function vertexAttrib2fvWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttrib2fv (index, v);
		
	}
	
	
	public inline function vertexAttrib3f (index:Int, v0:Float, v1:Float, v2:Float):Void {
		
		__context.vertexAttrib3f (index, v0, v1, v2);
		
	}
	
	
	public inline function vertexAttrib3fv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttrib3fv (index, v.toFloat32Array ());
		
	}
	
	
	//public function vertexAttrib3fv (index:Int, v:Float32Array):Void {
	//public function vertexAttrib3fv (index:Int, v:Array<Float>):Void {
	public inline function vertexAttrib3fvWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttrib3fv (index, v);
		
	}
	
	
	public inline function vertexAttrib4f (index:Int, v0:Float, v1:Float, v2:Float, v3:Float):Void {
		
		__context.vertexAttrib4f (index, v0, v1, v2, v3);
		
	}
	
	
	public inline function vertexAttrib4fv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttrib4fv (index, v.toFloat32Array ());
		
	}
	
	
	//public function vertexAttrib4fv (index:Int, v:Float32Array):Void {
	//public function vertexAttrib4fv (index:Int, v:Array<Float>):Void {
	public inline function vertexAttrib4fvWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttrib4fv (index, v);
		
	}
	
	
	public inline function vertexAttribDivisor (index:Int, divisor:Int):Void {
		
		__context.vertexAttribDivisor (index, divisor);
		
	}
	
	
	public inline function vertexAttribI4i (index:Int, v0:Int, v1:Int, v2:Int, v3:Int):Void {
		
		__context.vertexAttribI4i (index, v0, v1, v2, v3);
		
	}
	
	
	public inline function vertexAttribI4iv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttribI4iv (index, v.toInt32Array ());
		
	}
	
	
	//public function vertexAttribI4iv (index:Int, v:js.html.Int32Array) {
	//public function vertexAttribI4iv (index:Int, v:Array<Int>) {
	public inline function vertexAttribI4ivWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttribI4iv (index, v);
		
	}
	
	
	public inline function vertexAttribI4ui (index:Int, v0:Int, v1:Int, v2:Int, v3:Int):Void {
		
		__context.vertexAttribI4ui (index, v0, v1, v2, v3);
		
	}
	
	
	public inline function vertexAttribI4uiv (index:Int, v:DataPointer):Void {
		
		__context.vertexAttribI4uiv (index, v.toUInt32Array ());
		
	}
	
	
	//public function vertexAttribI4iv (index:Int, v:js.html.Uint32Array) {
	//public function vertexAttribI4iv (index:Int, v:Array<Int>) {
	public inline function vertexAttribI4uivWEBGL (index:Int, v:Dynamic):Void {
		
		__context.vertexAttribI4uiv (index, v);
		
	}
	
	
	public inline function vertexAttribIPointer (index:Int, size:Int, type:Int, stride:Int, offset:DataPointer):Void {
		
		__context.vertexAttribIPointer (index, size, type, stride, offset.toValue ());
		
	}
	
	
	public inline function vertexAttribPointer (index:Int, size:Int, type:Int, normalized:Bool, stride:Int, offset:Int):Void {
		
		__context.vertexAttribPointer (index, size, type, normalized, stride, offset);
		
	}
	
	
	public inline function viewport (x:Int, y:Int, width:Int, height:Int):Void {
		
		__context.viewport (x, y, width, height);
		
	}
	
	
	//public inline function waitSync (sync:GLSync, flags:Int, timeout:Dynamic):Void {
	//public inline function waitSync (sync:GLSync, flags:Int, timeout:Int64):Void {
	public inline function waitSync (sync:GLSync, flags:Int, timeout:Dynamic /*int64*/):Void {
		
		__context.waitSync (sync, flags, timeout);
		
	}
	
	
	#if (js && html5)
	private function get_canvas ():CanvasElement {
		
		return __context.canvas;
		
	}
	
	
	private function get_drawingBufferHeight ():Int {
		
		return __context.drawingBufferHeight;
		
	}
	
	
	private function get_drawingBufferWidth ():Int {
		
		return __context.drawingBufferWidth;
		
	}
	#end
	
	
}
