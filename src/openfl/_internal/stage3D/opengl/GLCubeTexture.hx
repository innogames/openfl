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
import openfl.display3D.textures.CubeTexture;
import openfl.errors.IllegalOperationError;
import openfl.utils.ByteArray;

@:access(openfl._internal.stage3D.SamplerState)
@:access(openfl.display3D.textures.CubeTexture)
@:access(openfl.display3D.Context3D)
class GLCubeTexture {
	public static function create(cubeTexture:CubeTexture):Void {
		cubeTexture.__textureTarget = GL.TEXTURE_CUBE_MAP;
		cubeTexture.__uploadedSides = 0;
	}

	public static function uploadCompressedTextureFromByteArray(cubeTexture:CubeTexture, renderSession:GLRenderSession, data:ByteArray,
			byteArrayOffset:UInt):Void {
		var reader = new ATFReader(data, byteArrayOffset);
		var alpha = reader.readHeader(cubeTexture.__size, cubeTexture.__size, true);

		var gl = renderSession.gl;

		gl.bindTexture(cubeTexture.__textureTarget, cubeTexture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		var hasTexture = false;

		reader.readTextures(function(side, level, gpuFormat, size, _, blockLength, bytes) {
			var format = GLTextureBase.__compressedTextureFormats.toTextureFormat(alpha, gpuFormat);
			if (format == 0)
				return;

			if (size == 0)
				return;

			hasTexture = true;
			cubeTexture.__format = format;
			cubeTexture.__internalFormat = format;

			gl.compressedTexImage2D(__sideToTarget(side), level, cubeTexture.__internalFormat, size, size, 0, bytes, 0, blockLength);
			GLUtils.checkGLError(gl);

			cubeTexture.__uploadedSides |= 1 << side;

			// __trackCompressedMemoryUsage (blockLength);
		});

		if (!hasTexture) {
			for (side in 0...6) {
				var data = new UInt8Array(cubeTexture.__size * cubeTexture.__size * 4);
				gl.texImage2D(__sideToTarget(side), 0, cubeTexture.__internalFormat, cubeTexture.__size, cubeTexture.__size, 0, cubeTexture.__format,
					GL.UNSIGNED_BYTE, data);
				GLUtils.checkGLError(gl);

				cubeTexture.__uploadedSides |= 1 << side;
			}
		}

		gl.bindTexture(cubeTexture.__textureTarget, null);
		GLUtils.checkGLError(gl);
	}

	public static function uploadFromBitmapData(cubeTexture:CubeTexture, renderSession:GLRenderSession, source:BitmapData, side:UInt, miplevel:UInt = 0,
			generateMipmap:Bool = false):Void {
		if (source == null)
			return;

		var size = cubeTexture.__size >> miplevel;

		if (size == 0)
			return;

		if (source.width != size || source.height != size) {
			var copy = new BitmapData(size, size, true, 0);
			copy.draw(source);
			source = copy;
		}

		var image = cubeTexture.__getImage(source);
		GLTextureBase.uploadFromImage(renderSession.gl, cubeTexture, image, miplevel, size, size, __sideToTarget(side));
		cubeTexture.__uploadedSides |= 1 << side;
	}

	public static function uploadFromByteArray(cubeTexture:CubeTexture, renderSession:GLRenderSession, data:ByteArray, byteArrayOffset:UInt, side:UInt,
			miplevel:UInt = 0):Void {
		if (data == null)
			return;

		#if js
		if (byteArrayOffset == 0) {
			uploadFromTypedArray(cubeTexture, renderSession, @:privateAccess (data : ByteArrayData).b, side, miplevel);
			return;
		}
		#end

		uploadFromTypedArray(cubeTexture, renderSession, new UInt8Array(data.toArrayBuffer(), byteArrayOffset), side, miplevel);
	}

	public static function uploadFromTypedArray(cubeTexture:CubeTexture, renderSession:GLRenderSession, data:ArrayBufferView, side:UInt,
			miplevel:UInt = 0):Void {
		var gl = renderSession.gl;

		var size = cubeTexture.__size >> miplevel;

		if (size == 0)
			return;

		var target = __sideToTarget(side);

		gl.bindTexture(cubeTexture.__textureTarget, cubeTexture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		gl.texImage2D(target, miplevel, cubeTexture.__internalFormat, size, size, 0, cubeTexture.__format, GL.UNSIGNED_BYTE, data);
		GLUtils.checkGLError(gl);

		gl.bindTexture(cubeTexture.__textureTarget, null);
		GLUtils.checkGLError(gl);

		cubeTexture.__uploadedSides |= 1 << side;

		// var memUsage = (size * size) * 4;
		// __trackMemoryUsage (memUsage);
	}

	public static function setSamplerState(cubeTexture:CubeTexture, renderSession:GLRenderSession, state:SamplerState) {
		if (!state.equals(cubeTexture.__samplerState)) {
			var gl = renderSession.gl;

			if (state.minFilter != GL.NEAREST && state.minFilter != GL.LINEAR && !state.mipmapGenerated) {
				gl.generateMipmap(GL.TEXTURE_CUBE_MAP);
				GLUtils.checkGLError(gl);

				state.mipmapGenerated = true;
			}

			if (state.maxAniso != 0.0) {
				gl.texParameterf(GL.TEXTURE_CUBE_MAP, Context3D.TEXTURE_MAX_ANISOTROPY_EXT, state.maxAniso);
				GLUtils.checkGLError(gl);
			}
		}

		GLTextureBase.setSamplerState(cubeTexture, renderSession, state);
	}

	static function __sideToTarget(side:UInt) {
		return switch (side) {
			case 0: GL.TEXTURE_CUBE_MAP_NEGATIVE_X;
			case 1: GL.TEXTURE_CUBE_MAP_POSITIVE_X;
			case 2: GL.TEXTURE_CUBE_MAP_NEGATIVE_Y;
			case 3: GL.TEXTURE_CUBE_MAP_POSITIVE_Y;
			case 4: GL.TEXTURE_CUBE_MAP_NEGATIVE_Z;
			case 5: GL.TEXTURE_CUBE_MAP_POSITIVE_Z;
			default: throw new IllegalOperationError();
		}
	}
}
