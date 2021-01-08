package openfl._internal.renderer.opengl;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.math.Matrix4;
import openfl.display.Graphics;
import openfl.display.Stage;
import openfl.geom.Matrix;

@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.display.Stage3D)
class GLRenderer {
	public var height:Int;
	public var width:Int;
	public var projectionFlipped:Matrix4;

	private var stage:Stage;
	private var renderSession:GLRenderSession;
	private var displayWidth:Int;
	private var displayHeight:Int;
	private var displayMatrix:Matrix;
	private var gl:GLRenderContext;
	private var matrix:Matrix4;
	private var offsetX:Int;
	private var offsetY:Int;

	public function new(stage:Stage, gl:GLRenderContext) {
		this.stage = stage;
		this.gl = gl;

		width = stage.stageWidth;
		height = stage.stageHeight;

		matrix = new Matrix4();

		if (gl != null) {
			if (Graphics.maxTextureWidth == null) {
				Graphics.maxTextureWidth = Graphics.maxTextureHeight = gl.getParameter(GL.MAX_TEXTURE_SIZE);
			}
			var maxTexturesLimit = if (stage.window.renderer.hasMajorPerformanceCaveat) 1 else -1;
			renderSession = new GLRenderSession(this, gl, maxTexturesLimit);
		}

		if (stage.stage3Ds[0].context3D == null) {
			stage.stage3Ds[0].__createContext(stage, renderSession);
		}

		var width = Std.int(stage.window.width * stage.window.scale);
		var height = Std.int(stage.window.height * stage.window.scale);

		resize(width, height);
	}

	public function clear():Void {
		if (gl == null) return;

		if (stage.__transparent) {
			gl.clearColor(0, 0, 0, 0);
		} else {
			gl.clearColor(stage.__colorSplit[0], stage.__colorSplit[1], stage.__colorSplit[2], 1);
		}

		gl.clear(GL.COLOR_BUFFER_BIT);
	}

	static var getMatrixHelperMatrix = new Matrix();

	public function getDisplayTransformTempMatrix(transform:Matrix, snapToPixel:Bool):Matrix {
		var matrix = getMatrixHelperMatrix;
		matrix.copyFrom(transform);
		matrix.concat(displayMatrix);

		if (snapToPixel) {
			matrix.tx = Math.round(matrix.tx);
			matrix.ty = Math.round(matrix.ty);
		}

		return matrix;
	}

	public function getMatrix(transform:Matrix, snapToPixel:Bool = false):Matrix4 {
		var _matrix = getDisplayTransformTempMatrix(transform, renderSession.roundPixels || snapToPixel);

		matrix.identity();
		matrix[0] = _matrix.a;
		matrix[1] = _matrix.b;
		matrix[4] = _matrix.c;
		matrix[5] = _matrix.d;
		matrix[12] = _matrix.tx;
		matrix[13] = _matrix.ty;
		matrix.append(projectionFlipped);

		return matrix;
	}

	public function render():Void {
		if (gl == null) return;

		gl.viewport(offsetX, offsetY, displayWidth, displayHeight);

		renderSession.pixelRatio = stage.window.scale;

		renderSession.allowSmoothing = (stage.quality != LOW);
		renderSession.forceSmoothing = #if always_smooth_on_upscale (displayMatrix.a != 1 || displayMatrix.d != 1); #else false; #end

		// setup projection matrix for the batcher as it's an uniform value for all the draw calls
		renderSession.batcher.projectionMatrix = projectionFlipped;
		// also pass the viewport to the batcher because it uses it for the out-of-screen quad culling
		renderSession.batcher.setViewport(offsetX, offsetY, displayWidth, displayHeight);

		stage.__renderGL(renderSession);

		// flush whatever is left in the batch to render
		renderSession.batcher.flush();

		if (offsetX > 0 || offsetY > 0) {
			gl.clearColor(0, 0, 0, 1);
			gl.enable(GL.SCISSOR_TEST);

			if (offsetX > 0) {
				gl.scissor(0, 0, offsetX, height);
				gl.clear(GL.COLOR_BUFFER_BIT);

				gl.scissor(offsetX + displayWidth, 0, width, height);
				gl.clear(GL.COLOR_BUFFER_BIT);
			}

			if (offsetY > 0) {
				gl.scissor(0, 0, width, offsetY);
				gl.clear(GL.COLOR_BUFFER_BIT);

				gl.scissor(0, offsetY + displayHeight, width, height);
				gl.clear(GL.COLOR_BUFFER_BIT);
			}

			gl.disable(GL.SCISSOR_TEST);
		}
	}

	public function renderStage3D():Void {
		for (stage3D in stage.stage3Ds) {
			stage3D.__renderGL(stage, renderSession);
		}
	}

	public function resize(width:Int, height:Int):Void {
		this.width = width;
		this.height = height;

		displayMatrix = stage.__displayMatrix;

		var w = stage.stageWidth;
		var h = stage.stageHeight;

		offsetX = Math.round(displayMatrix.__transformX(0, 0));
		offsetY = Math.round(displayMatrix.__transformY(0, 0));
		displayWidth = Math.round(displayMatrix.__transformX(w, 0) - offsetX);
		displayHeight = Math.round(displayMatrix.__transformY(0, h) - offsetY);

		projectionFlipped = Matrix4.createOrtho(offsetX, displayWidth + offsetX, displayHeight + offsetY, offsetY, -1000, 1000);
	}
}
