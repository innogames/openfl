package openfl.display3D.textures;

import haxe.Timer;
import lime.utils.ArrayBufferView;
import openfl._internal.stage3D.opengl.GLCubeTexture;
import openfl._internal.stage3D.SamplerState;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.utils.ByteArray;

@:access(openfl.display3D.Context3D)
final class CubeTexture extends TextureBase {
	private var __size:Int;
	private var __uploadedSides:Int;

	private function new(context:Context3D, size:Int, format:Context3DTextureFormat, optimizeForRenderToTexture:Bool, streamingLevels:Int) {
		super(context);

		__size = size;
		__width = __height = __size;
		// __format = format;
		__optimizeForRenderToTexture = optimizeForRenderToTexture;
		__streamingLevels = streamingLevels;

		GLCubeTexture.create(this);
	}

	public function uploadCompressedTextureFromByteArray(data:ByteArray, byteArrayOffset:UInt, async:Bool = false):Void {
		if (!async) {
			GLCubeTexture.uploadCompressedTextureFromByteArray(this, __context.__renderSession, data, byteArrayOffset);
		} else {
			Timer.delay(function() {
				GLCubeTexture.uploadCompressedTextureFromByteArray(this, __context.__renderSession, data, byteArrayOffset);
				dispatchEvent(new Event(Event.TEXTURE_READY));
			}, 1);
		}
	}

	public function uploadFromBitmapData(source:BitmapData, side:UInt, miplevel:UInt = 0, generateMipmap:Bool = false):Void {
		GLCubeTexture.uploadFromBitmapData(this, __context.__renderSession, source, side, miplevel, generateMipmap);
	}

	public function uploadFromByteArray(data:ByteArray, byteArrayOffset:UInt, side:UInt, miplevel:UInt = 0):Void {
		GLCubeTexture.uploadFromByteArray(this, __context.__renderSession, data, byteArrayOffset, side, miplevel);
	}

	public function uploadFromTypedArray(data:ArrayBufferView, side:UInt, miplevel:UInt = 0):Void {
		GLCubeTexture.uploadFromTypedArray(this, __context.__renderSession, data, side, miplevel);
	}

	private override function __setSamplerState(state:SamplerState) {
		GLCubeTexture.setSamplerState(this, __context.__renderSession, state);
	}
}
