package openfl._internal.stage3D.opengl;

import lime.graphics.opengl.GL;
import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;
import openfl._internal.renderer.opengl.GLRenderSession;
import openfl._internal.stage3D.GLUtils;
import openfl._internal.stage3D.SamplerState;
import openfl._internal.stage3D.atf.ATFReader;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.Texture;
import openfl.utils.ByteArray;

@:access(openfl._internal.stage3D.SamplerState)
@:access(openfl.display3D.textures.Texture)
@:access(openfl.display3D.Context3D)
class GLTexture {
	public static function create(texture:Texture, renderSession:GLRenderSession):Void {
		texture.__textureTarget = GL.TEXTURE_2D;
		uploadFromTypedArray(texture, renderSession, null);
	}

	public static function uploadCompressedTextureFromByteArray(texture:Texture, renderSession:GLRenderSession, data:ByteArray, byteArrayOffset:UInt):Void {
		var reader = new ATFReader(data, byteArrayOffset);
		var alpha = reader.readHeader(texture.__width, texture.__height, false);

		var gl = renderSession.gl;

		gl.bindTexture(texture.__textureTarget, texture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		var hasTexture = false;

		reader.readTextures(function(target, level, gpuFormat, width, height, blockLength, bytes) {
			var format = GLTextureBase.__compressedTextureFormats.toTextureFormat(alpha, gpuFormat);
			if (format == 0)
				return;

			hasTexture = true;
			texture.__format = format;
			texture.__internalFormat = format;

			gl.compressedTexImage2D(texture.__textureTarget, level, texture.__internalFormat, width, height, 0, bytes, 0, blockLength);
			GLUtils.checkGLError(gl);

			// __trackCompressedMemoryUsage (blockLength);
		});

		if (!hasTexture) {
			var data = new UInt8Array(texture.__width * texture.__height * 4);
			gl.texImage2D(texture.__textureTarget, 0, texture.__internalFormat, texture.__width, texture.__height, 0, texture.__format, GL.UNSIGNED_BYTE,
				data);
			GLUtils.checkGLError(gl);
		}

		gl.bindTexture(texture.__textureTarget, null);
		GLUtils.checkGLError(gl);
	}

	public static function uploadFromBitmapData(texture:Texture, renderSession:GLRenderSession, source:BitmapData, miplevel:UInt = 0,
			generateMipmap:Bool = false):Void {
		if (source == null)
			return;

		var width = texture.__width >> miplevel;
		var height = texture.__height >> miplevel;

		if (width == 0 && height == 0)
			return;

		if (width == 0)
			width = 1;
		if (height == 0)
			height = 1;

		if (source.width != width || source.height != height) {
			var copy = new BitmapData(width, height, true, 0);
			copy.draw(source);
			source = copy;
		}

		var image = texture.__getImage(source);
		GLTextureBase.uploadFromImage(renderSession.gl, texture, image, miplevel, width, height);
	}

	public static function uploadFromByteArray(texture:Texture, renderSession:GLRenderSession, data:ByteArray, byteArrayOffset:UInt, miplevel:UInt = 0):Void {
		if (data == null)
			return;

		#if js
		if (byteArrayOffset == 0) {
			uploadFromTypedArray(texture, renderSession, @:privateAccess (data : ByteArrayData).b, miplevel);
			return;
		}
		#end

		uploadFromTypedArray(texture, renderSession, new UInt8Array(data.toArrayBuffer(), byteArrayOffset), miplevel);
	}

	public static function uploadFromTypedArray(texture:Texture, renderSession:GLRenderSession, data:ArrayBufferView, miplevel:UInt = 0):Void {
		var gl = renderSession.gl;

		var width = texture.__width >> miplevel;
		var height = texture.__height >> miplevel;

		if (width == 0 && height == 0)
			return;

		if (width == 0)
			width = 1;
		if (height == 0)
			height = 1;

		gl.bindTexture(texture.__textureTarget, texture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		gl.texImage2D(texture.__textureTarget, miplevel, texture.__internalFormat, width, height, 0, texture.__format, GL.UNSIGNED_BYTE, data);
		GLUtils.checkGLError(gl);

		gl.bindTexture(texture.__textureTarget, null);
		GLUtils.checkGLError(gl);

		// var memUsage = (width * height) * 4;
		// __trackMemoryUsage (memUsage);
	}

	public static function setSamplerState(texture:Texture, renderSession:GLRenderSession, state:SamplerState) {
		if (!state.equals(texture.__samplerState)) {
			var gl = renderSession.gl;

			if (state.minFilter != GL.NEAREST && state.minFilter != GL.LINEAR && !state.mipmapGenerated) {
				gl.generateMipmap(GL.TEXTURE_2D);
				GLUtils.checkGLError(gl);

				state.mipmapGenerated = true;
			}

			if (state.maxAniso != 0.0) {
				gl.texParameterf(GL.TEXTURE_2D, Context3D.TEXTURE_MAX_ANISOTROPY_EXT, state.maxAniso);
				GLUtils.checkGLError(gl);
			}
		}

		GLTextureBase.setSamplerState(texture, renderSession, state);
	}
}
