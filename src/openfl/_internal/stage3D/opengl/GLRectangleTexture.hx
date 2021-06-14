package openfl._internal.stage3D.opengl;

import lime.graphics.opengl.GL;
import lime.utils.ArrayBufferView;
import lime.utils.UInt8Array;
import openfl._internal.renderer.opengl.GLRenderSession;
import openfl._internal.stage3D.GLUtils;
import openfl._internal.stage3D.SamplerState;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.textures.RectangleTexture;
import openfl.utils.ByteArray;

@:access(openfl._internal.stage3D.SamplerState)
@:access(openfl.display3D.textures.RectangleTexture)
@:access(openfl.display3D.Context3D)
class GLRectangleTexture {
	public static function create(rectangleTexture:RectangleTexture, renderSession:GLRenderSession):Void {
		rectangleTexture.__textureTarget = GL.TEXTURE_2D;
		uploadFromTypedArray(rectangleTexture, renderSession, null);
	}

	public static function uploadFromBitmapData(rectangleTexture:RectangleTexture, renderSession:GLRenderSession, source:BitmapData):Void {
		if (source == null)
			return;

		var width = rectangleTexture.__width;
		var height = rectangleTexture.__height;

		var image = rectangleTexture.__getImage(source);
		GLTextureBase.uploadFromImage(renderSession.gl, rectangleTexture, image, 0, width, height);
	}

	public static function uploadFromByteArray(rectangleTexture:RectangleTexture, renderSession:GLRenderSession, data:ByteArray, byteArrayOffset:UInt):Void {
		if (data == null)
			return;

		#if js
		if (byteArrayOffset == 0) {
			uploadFromTypedArray(rectangleTexture, renderSession, @:privateAccess (data : ByteArrayData).b);
			return;
		}
		#end

		uploadFromTypedArray(rectangleTexture, renderSession, new UInt8Array(data.toArrayBuffer(), byteArrayOffset));
	}

	public static function uploadFromTypedArray(rectangleTexture:RectangleTexture, renderSession:GLRenderSession, data:ArrayBufferView):Void {
		var gl = renderSession.gl;

		var width = rectangleTexture.__width;
		var height = rectangleTexture.__height;

		gl.bindTexture(rectangleTexture.__textureTarget, rectangleTexture.__textureData.glTexture);
		GLUtils.checkGLError(gl);

		gl.texImage2D(rectangleTexture.__textureTarget, 0, rectangleTexture.__internalFormat, width, height, 0, rectangleTexture.__format, GL.UNSIGNED_BYTE,
			data);
		GLUtils.checkGLError(gl);

		gl.bindTexture(rectangleTexture.__textureTarget, null);
		GLUtils.checkGLError(gl);

		// var memUsage = (width * height) * 4;
		// __trackMemoryUsage (memUsage);
	}

	public static function setSamplerState(rectangleTexture:RectangleTexture, renderSession:GLRenderSession, state:SamplerState) {
		if (!state.equals(rectangleTexture.__samplerState)) {
			var gl = renderSession.gl;

			if (state.maxAniso != 0.0) {
				gl.texParameterf(GL.TEXTURE_2D, Context3D.TEXTURE_MAX_ANISOTROPY_EXT, state.maxAniso);
				GLUtils.checkGLError(gl);
			}
		}

		GLTextureBase.setSamplerState(rectangleTexture, renderSession, state);
	}
}
