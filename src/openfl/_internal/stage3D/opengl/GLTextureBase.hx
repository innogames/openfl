package openfl._internal.stage3D.opengl;

import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.utils.ImageCanvasUtil;
import openfl._internal.renderer.opengl.GLRenderSession;
import openfl._internal.renderer.opengl.batcher.TextureData;
import openfl._internal.stage3D.GLCompressedTextureFormats;
import openfl._internal.stage3D.GLUtils;
import openfl._internal.stage3D.SamplerState;
import openfl.display.BitmapData;
import openfl.display3D.textures.TextureBase;

@:access(openfl._internal.stage3D.SamplerState)
@:access(openfl.display3D.textures.TextureBase)
@:access(openfl.display.BitmapData)
class GLTextureBase {
	public static var __supportsBGRA:Null<Bool> = null;
	public static var __textureFormat:Int;
	public static var __textureInternalFormat:Int;

	public static var __compressedTextureFormats:Null<GLCompressedTextureFormats> = null;

	public static function reset() {
		__supportsBGRA = null;
		__compressedTextureFormats = null;
	}

	public static function create(textureBase:TextureBase, renderSession:GLRenderSession):Void {
		var gl = renderSession.gl;

		textureBase.__textureData = new TextureData(gl.createTexture());
		textureBase.__textureContext = gl;

		if (__supportsBGRA == null) {
			__textureInternalFormat = GL.RGBA;

			var bgraExtension = null;
			#if (!js || !html5)
			bgraExtension = gl.getExtension("EXT_bgra");
			if (bgraExtension == null)
				bgraExtension = gl.getExtension("EXT_texture_format_BGRA8888");
			if (bgraExtension == null)
				bgraExtension = gl.getExtension("APPLE_texture_format_BGRA8888");
			#end

			if (bgraExtension != null) {
				__supportsBGRA = true;
				__textureFormat = bgraExtension.BGRA_EXT;
			} else {
				__supportsBGRA = false;
				__textureFormat = GL.RGBA;
			}
		}

		if (__compressedTextureFormats == null) {
			__compressedTextureFormats = new GLCompressedTextureFormats(gl);
		}

		textureBase.__internalFormat = __textureInternalFormat;
		textureBase.__format = __textureFormat;
	}

	public static function dispose(textureBase:TextureBase, renderSession:GLRenderSession):Void {
		var gl = renderSession.gl;

		if (textureBase.__alphaTexture != null) {
			textureBase.__alphaTexture.dispose();
		}

		if (textureBase.__depthStencilRenderbuffer != null) {
			gl.deleteRenderbuffer(textureBase.__depthStencilRenderbuffer);
		}

		if (textureBase.__depthRenderbuffer != null) {
			gl.deleteRenderbuffer(textureBase.__depthRenderbuffer);
		}

		if (textureBase.__stencilRenderbuffer != null) {
			gl.deleteRenderbuffer(textureBase.__stencilRenderbuffer);
		}

		if (textureBase.__framebuffer != null) {
			gl.deleteFramebuffer(textureBase.__framebuffer);
		}

		gl.deleteTexture(textureBase.__textureData.glTexture);

		// if (__compressedMemoryUsage > 0) {

		// 	__context.__statsDecrement (Context3D.Context3DTelemetry.COUNT_TEXTURE_COMPRESSED);
		// 	var currentCompressedMemory = __context.__statsSubtract (Context3D.Context3DTelemetry.MEM_TEXTURE_COMPRESSED, __compressedMemoryUsage);

		// 	#if debug
		// 	if (__outputTextureMemoryUsage) {

		// 		trace (" - Texture Compressed GPU Memory (-" + __compressedMemoryUsage + ") - Current Compressed Memory : " + currentCompressedMemory);

		// 	}
		// 	#end

		// 	__compressedMemoryUsage = 0;

		// }

		// if (__memoryUsage > 0) {

		// 	__context.__statsDecrement (Context3D.Context3DTelemetry.COUNT_TEXTURE);
		// 	var currentMemory = __context.__statsSubtract (Context3D.Context3DTelemetry.MEM_TEXTURE, __memoryUsage);

		// 	#if debug
		// 	if (__outputTextureMemoryUsage) {

		// 		trace (" - Texture GPU Memory (-" + __memoryUsage + ") - Current Memory : " + currentMemory);

		// 	}
		// 	#end

		// 	__memoryUsage = 0;

		// }
	}

	public static function getImage(textureBase:TextureBase, renderSession:GLRenderSession, bitmapData:BitmapData):Image {
		if (!bitmapData.__isValid || !bitmapData.__prepareImage()) {
			return null;
		}

		var image = bitmapData.image;

		#if (js && html5)
		ImageCanvasUtil.sync(image, false);
		#end

		#if (js && html5)
		var gl = renderSession.gl;

		if (image.type != DATA && !image.premultiplied) {
			gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);
		} else if (!image.premultiplied && image.transparent) {
			gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, 0);
			image = image.clone();
			image.premultiplied = true;
		}

		// TODO: Some way to support BGRA on WebGL?

		if (image.format != RGBA32) {
			image = image.clone();
			image.format = RGBA32;
			image.buffer.premultiplied = true;
			#if openfl_power_of_two
			image.powerOfTwo = true;
			#end
		}
		#else
		if (#if openfl_power_of_two !image.powerOfTwo || #end (!image.premultiplied && image.transparent)) {
			image = image.clone();
			image.premultiplied = true;
			#if openfl_power_of_two
			image.powerOfTwo = true;
			#end
		}
		#end

		return image;
	}

	public static function setSamplerState(textureBase:TextureBase, renderSession:GLRenderSession, state:SamplerState):Void {
		if (!state.equals(textureBase.__samplerState)) {
			var gl = renderSession.gl;

			gl.bindTexture(textureBase.__textureTarget, textureBase.__textureData.glTexture);
			GLUtils.checkGLError(gl);
			gl.texParameteri(textureBase.__textureTarget, GL.TEXTURE_MIN_FILTER, state.minFilter);
			GLUtils.checkGLError(gl);
			gl.texParameteri(textureBase.__textureTarget, GL.TEXTURE_MAG_FILTER, state.magFilter);
			GLUtils.checkGLError(gl);
			gl.texParameteri(textureBase.__textureTarget, GL.TEXTURE_WRAP_S, state.wrapModeS);
			GLUtils.checkGLError(gl);
			gl.texParameteri(textureBase.__textureTarget, GL.TEXTURE_WRAP_T, state.wrapModeT);
			GLUtils.checkGLError(gl);

			if (state.lodBias != 0.0) {
				// TODO
				// throw new IllegalOperationError("Lod bias setting not supported yet");
			}

			textureBase.__samplerState = state;
			textureBase.__samplerState.__samplerDirty = false;
		}
	}

	public static function uploadFromImage(gl:GL, texture:TextureBase, image:Image, miplevel:Int, width:Int, height:Int, uploadTarget:Int = -1) {
		if (image == null)
			return;

		if (uploadTarget == -1) uploadTarget = texture.__textureTarget;

		gl.bindTexture(texture.__textureTarget, texture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		if (image.type == DATA) {
			gl.texImage2D(uploadTarget, miplevel, texture.__internalFormat, width, height, 0, texture.__format, GL.UNSIGNED_BYTE, image.data);
		} else {
			gl.texImage2D(uploadTarget, miplevel, texture.__internalFormat, texture.__format, GL.UNSIGNED_BYTE, image.src);
		}
		GLUtils.checkGLError(gl);

		gl.bindTexture(texture.__textureTarget, null);
		GLUtils.checkGLError(gl);
	}
}
