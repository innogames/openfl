package openfl._internal.renderer.opengl;

import js.html.webgl.Framebuffer;
import js.html.webgl.Texture;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.math.Matrix4;
import openfl.display.Graphics;
import openfl.display.Stage;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

@:access(openfl.display.Graphics)
@:access(openfl.display.Stage)
@:access(openfl.display.Stage3D)
class GLRenderer {
	public var height:Int;
	public var width:Int;
	public var renderToTexture(default,null):Bool = false;

	final stage:Stage;
	final gl:GLRenderContext;
	final renderSession:GLRenderSession;

	var displayMatrix:Matrix;
	var offsetX:Int;
	var offsetY:Int;
	var displayWidth:Int;
	var displayHeight:Int;
	var projectionFlipped:Matrix4;

	var _viewportX:Int;
	var _viewportY:Int;
	var _viewportWidth:Int;
	var _viewportHeight:Int;
	var _currentFramebuffer:Framebuffer;
	var _oldBatcherViewport:Rectangle;

	function _setViewport(x:Int, y:Int, width:Int, height:Int) {
		_viewportX = x;
		_viewportY = y;
		_viewportWidth = width;
		_viewportHeight = height;
		gl.viewport(x, y, width, height);
		// also pass the viewport to the batcher because it uses it for the out-of-screen quad culling
		renderSession.batcher.setViewport(0, 0, width, height);
	}

	function _bindFramebuffer(framebuffer:Framebuffer) {
		_currentFramebuffer = framebuffer;
		gl.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
	}

	public function new(stage:Stage, gl:GLRenderContext) {
		this.stage = stage;
		this.gl = gl;

		displayMatrix = stage.__displayMatrix;

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

	public extern inline function withTextureFramebuffer(texture:Texture, f:()->Void) {
		var oldFramebuffer = _currentFramebuffer;
		var framebuffer = gl.createFramebuffer(); // TODO: save this for re-renders?
		_bindFramebuffer(framebuffer);
		gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
		f();
		_bindFramebuffer(oldFramebuffer);
		gl.deleteFramebuffer(framebuffer);
	}

	static final renderToTextureDisplayMatrix = new Matrix();

	@:access(openfl._internal.renderer.opengl.batcher.BatchRenderer.viewport)
	public extern inline function invokeRenderToTexture(width:Int, height:Int, texture:Texture, pixelRatio:Float, f:GLRenderSession->Void) {
		var renderSession = this.renderSession;

		renderSession.batcher.flush();

		var oldDisplayMatrix = displayMatrix;
		var oldProjectionFlipped = this.projectionFlipped;
		var oldBatcherProjectionMatrix = renderSession.batcher.projectionMatrix; // this can be different from projectionFlipped if Starling sets it
		var oldRenderHeight = this.height;
		var oldPixelRatio = renderSession.pixelRatio;
		var oldSmoothing = renderSession.allowSmoothing;
		var oldClearRenderDirty = renderSession.clearRenderDirty;
		var oldBlendMode = renderSession.blendModeManager.currentBlendMode;
		var oldShader = renderSession.shaderManager.currentShader;
		var oldStencilReference = renderSession.maskManager.suspend();
		var oldViewportX = _viewportX;
		var oldViewportY = _viewportY;
		var oldViewportWidth = _viewportWidth;
		var oldViewportHeight = _viewportHeight;
		var oldFramebuffer = _currentFramebuffer;
		var oldRenderToTexture = renderToTexture;

		// preserve current batcher viewport as well as it can be different from GL viewport, when Starling is involved...
		if (_oldBatcherViewport == null) {
			_oldBatcherViewport = renderSession.batcher.viewport.clone();
		} else {
			_oldBatcherViewport.copyFrom(renderSession.batcher.viewport);
		}

		renderSession.pixelRatio = pixelRatio;
		renderToTextureDisplayMatrix.a = renderToTextureDisplayMatrix.d = pixelRatio;
		displayMatrix = renderToTextureDisplayMatrix;

		renderToTexture = true;

		this.projectionFlipped = Matrix4.createOrtho(0, width, 0, height, -1000, 1000); // not flipped actually
		this.height = height;
		renderSession.batcher.projectionMatrix = projectionFlipped;
		_setViewport(0, 0, width, height);

		var framebuffer = gl.createFramebuffer(); // TODO: save this for re-renders?
		_bindFramebuffer(framebuffer);
		gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);

		// TODO: only create if there are masks inside the rendered object!
		var depthStencilBuffer = gl.createRenderbuffer();
		gl.bindRenderbuffer(GL.RENDERBUFFER, depthStencilBuffer);
		gl.renderbufferStorage(GL.RENDERBUFFER, GL.DEPTH_STENCIL, width, height);
		gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.STENCIL_ATTACHMENT, GL.RENDERBUFFER, depthStencilBuffer);
		gl.bindRenderbuffer(GL.RENDERBUFFER, null);

		f(renderSession);

		_setViewport(oldViewportX, oldViewportY, oldViewportWidth, oldViewportHeight);
		this.projectionFlipped = oldProjectionFlipped;
		this.height = oldRenderHeight;
		renderToTexture = oldRenderToTexture;
		displayMatrix = oldDisplayMatrix;
		renderSession.pixelRatio = oldPixelRatio;
		renderSession.allowSmoothing = oldSmoothing;
		renderSession.clearRenderDirty = oldClearRenderDirty;
		renderSession.batcher.projectionMatrix = oldBatcherProjectionMatrix;
		renderSession.batcher.setViewport(_oldBatcherViewport.x, _oldBatcherViewport.y, _oldBatcherViewport.width, _oldBatcherViewport.height);
		renderSession.blendModeManager.setBlendMode(oldBlendMode);
		renderSession.shaderManager.setShader(oldShader);
		renderSession.maskManager.resume(oldStencilReference);
		_bindFramebuffer(oldFramebuffer);
		gl.deleteFramebuffer(framebuffer);
		gl.deleteRenderbuffer(depthStencilBuffer);
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

	static final getDisplayTransformTempMatrixHelperMatrix = new Matrix();
	static final getMatrixHelperMatrix:Matrix4 = new Matrix4();

	public function getDisplayTransformTempMatrix(transform:Matrix, snapToPixel:Bool):Matrix {
		var matrix = getDisplayTransformTempMatrixHelperMatrix;
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

		var matrix = getMatrixHelperMatrix;
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

		_setViewport(offsetX, offsetY, displayWidth, displayHeight);

		renderSession.pixelRatio = stage.window.scale;

		renderSession.allowSmoothing = (stage.quality != LOW);
		renderSession.forceSmoothing = #if always_smooth_on_upscale (displayMatrix.a != 1 || displayMatrix.d != 1); #else false; #end

		// setup projection matrix for the batcher as it's an uniform value for all the draw calls
		renderSession.batcher.projectionMatrix = projectionFlipped;

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
		// TODO: figure out and document the difference between width/height, stageWidth/stageHeight and displayWidth/displayHeight
		this.width = width;
		this.height = height;

		var w = stage.stageWidth;
		var h = stage.stageHeight;

		offsetX = Math.round(displayMatrix.__transformX(0, 0));
		offsetY = Math.round(displayMatrix.__transformY(0, 0));
		displayWidth = Math.round(displayMatrix.__transformX(w, 0) - offsetX);
		displayHeight = Math.round(displayMatrix.__transformY(0, h) - offsetY);

		projectionFlipped = Matrix4.createOrtho(offsetX, displayWidth + offsetX, displayHeight + offsetY, offsetY, -1000, 1000);
	}
}
