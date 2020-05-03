package openfl._internal.stage3D.opengl;

import lime.graphics.opengl.GL;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.batcher.TextureData;
import openfl._internal.stage3D.GLUtils;
import openfl.display3D.textures.VideoTexture;

@:access(openfl.display3D.textures.VideoTexture)
@:access(openfl.net.NetStream)
class GLVideoTexture {
	public static function create(videoTexture:VideoTexture, renderSession:RenderSession):Void {
		var gl = renderSession.gl;
		videoTexture.__textureTarget = GL.TEXTURE_2D;
	}

	public static function getTexture(videoTexture:VideoTexture, renderSession:RenderSession):TextureData {
		if (!videoTexture.__netStream.__video.paused) {
			var gl = renderSession.gl;

			gl.bindTexture(videoTexture.__textureTarget, videoTexture.__textureData.glTexture);
			GLUtils.checkGLError(gl);

			gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, GL.RGBA, GL.UNSIGNED_BYTE, videoTexture.__netStream.__video);
			GLUtils.checkGLError(gl);
		}

		return videoTexture.__textureData;
	}
}
