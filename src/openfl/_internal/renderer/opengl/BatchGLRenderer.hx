package openfl._internal.renderer.opengl;

import openfl._internal.renderer.RenderSession;
import openfl.display.Stage;
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import haxe.ds.Vector;


import openfl._internal.renderer.RenderSession;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.WebGLContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import openfl.geom.Matrix;
import openfl.geom.ColorTransform;
import openfl.display.Shader;
import openfl.display.BitmapData;
import lime.utils.Float32Array;
import lime.utils.Int16Array;

class Painter {
	var currentBatch:QuadBatch;
	var renderSession:RenderSession;

	public function new(renderSession:RenderSession) {
		this.renderSession = renderSession;
	}

	public function batchQuad(
		width:Float, height:Float,
		transform:Matrix,
		shader:Shader, bitmapData:BitmapData,
		u1:Float, v1:Float,
		u2:Float, v2:Float,
		u3:Float, v3:Float,
		u4:Float, v4:Float,
		alpha:Float,
		colorTransform:ColorTransform
	) {
		if (currentBatch == null) {
			currentBatch = new QuadBatch(shader, bitmapData);
		} else if (!currentBatch.canBatch(renderSession.gl, shader, bitmapData)) {
			currentBatch.render(renderSession);
			currentBatch = new QuadBatch(shader, bitmapData);
		}

		var redMultiplier = colorTransform.redMultiplier;
		var greenMultiplier = colorTransform.greenMultiplier;
		var blueMultiplier = colorTransform.blueMultiplier;
		var alphaMultiplier = colorTransform.alphaMultiplier;
		var redOffset = colorTransform.redOffset / 255;
		var greenOffset = colorTransform.greenOffset / 255;
		var blueOffset = colorTransform.blueOffset / 255;
		var alphaOffset = colorTransform.alphaOffset / 255;

		var x1 = transform.__transformX(0, 0);
		var y1 = transform.__transformY(0, 0);

		var x2 = transform.__transformX(width, 0);
		var y2 = transform.__transformY(width, 0);

		var x3 = transform.__transformX(0, height);
		var y3 = transform.__transformY(0, height);

		var x4 = transform.__transformX(width, height);
		var y4 = transform.__transformY(width, height);

		currentBatch.addQuad(
			x1, y1, u1, v1,
			x2, y2, u2, v2,
			x3, y3, u3, v3,
			x4, y4, u4, v4,
			alpha,
			redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier,
			redOffset, greenOffset, blueOffset, alphaOffset
		);
	}

	public function finishBatch() {
		if (currentBatch == null)
			return;
		currentBatch.render(renderSession);
		currentBatch = null;
	}
}

class QuadBatch {
	static inline var STRIDE = 26;

	var vertexData:Float32Array;
	var indexData:Int16Array;
	var numQuads:Int;
	var shader:Shader;
	var bitmapData:BitmapData;

	public function new(shader, bitmapData) {
		this.shader = shader;
		this.bitmapData = bitmapData;
		vertexData = new Float32Array(0);
		indexData = new Int16Array(0);
		numQuads = 0;
	}

	public function canBatch(gl:GLRenderContext, newShader:Shader, newBitmapData:BitmapData):Bool {
		return (shader == newShader && bitmapData.getTexture(gl) == newBitmapData.getTexture(gl));
	}

	function resize(capacity:Int) {
		var oldCapacity = numQuads;
		if (oldCapacity == capacity)
			return;

		numQuads = capacity;

		var oldVertexData = vertexData;
		var oldIndexData = indexData;

		vertexData = new Float32Array(STRIDE * 4 * capacity);
		indexData = new Int16Array(6 * capacity);

		vertexData.set(oldVertexData);
		indexData.set(oldIndexData);

		for (i in oldCapacity...numQuads) {
			indexData[i * 6    ] = i * 4;
			indexData[i * 6 + 1] = i * 4 + 1;
			indexData[i * 6 + 2] = i * 4 + 2;
			indexData[i * 6 + 3] = i * 4 + 1;
			indexData[i * 6 + 4] = i * 4 + 2;
			indexData[i * 6 + 5] = i * 4 + 3;
		}
	}

	public function addQuad(
		x1:Float, y1:Float, u1:Float, v1:Float,
		x2:Float, y2:Float, u2:Float, v2:Float,
		x3:Float, y3:Float, u3:Float, v3:Float,
		x4:Float, y4:Float, u4:Float, v4:Float,
		alpha:Float, redMultiplier:Float, greenMultiplier:Float, blueMultiplier:Float, alphaMultiplier:Float, redOffset:Float, greenOffset:Float, blueOffset:Float, alphaOffset:Float
	) {
		var vertexId = numQuads * 4;
		resize(numQuads + 1);
		addVertex(vertexId,     x1, y1, u1, v1, alpha, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		addVertex(vertexId + 1, x2, y2, u2, v2, alpha, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		addVertex(vertexId + 2, x3, y3, u3, v3, alpha, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		addVertex(vertexId + 3, x4, y4, u4, v4, alpha, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
	}

	inline function addVertex(vertexId:Int, x:Float, y:Float, u:Float, v:Float, alpha:Float, redMultiplier:Float, greenMultiplier:Float, blueMultiplier:Float, alphaMultiplier:Float, redOffset:Float, greenOffset:Float, blueOffset:Float, alphaOffset:Float) {
		var offset = vertexId * STRIDE;
		vertexData[offset] = x;
		vertexData[offset + 1] = y;
		vertexData[offset + 3] = u;
		vertexData[offset + 4] = v;
		vertexData[offset + 5] = alpha;
		vertexData[offset + 6] = redMultiplier;
		vertexData[offset + 11] = greenMultiplier;
		vertexData[offset + 16] = blueMultiplier;
		vertexData[offset + 21] = alphaMultiplier;
		vertexData[offset + 22] = redOffset;
		vertexData[offset + 23] = greenOffset;
		vertexData[offset + 24] = blueOffset;
		vertexData[offset + 25] = alphaOffset;
	}

	function bindBuffers(gl:WebGLContext) {
		var buffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertexData, gl.STATIC_DRAW);

		var indexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indexData, gl.STATIC_DRAW);
	}

	@:access(openfl.geom.Matrix)
	public function render(renderSession:RenderSession) {
		if (numQuads == 0)
			return;

		var shader = renderSession.shaderManager.initShader(shader);
		renderSession.shaderManager.setShader(shader);

		shader.data.uImage0.input = bitmapData;
		shader.data.uMatrix.value = (cast renderSession.renderer : openfl._internal.renderer.opengl.GLRenderer).getMatrix(@:privateAccess Matrix.__identity);
		shader.data.uColorTransform.value = [true]; // no idea why array is required

		renderSession.shaderManager.updateShader(shader);

		var gl = renderSession.gl;

		bindBuffers(gl);

		gl.vertexAttribPointer(shader.data.aPosition.index, 3, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index, 1, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);

		gl.vertexAttribPointer(shader.data.aColorMultipliers0.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aColorMultipliers1.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 10 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aColorMultipliers2.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 14 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aColorMultipliers3.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 18 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aColorOffsets.index, 4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 22 * Float32Array.BYTES_PER_ELEMENT);

		gl.drawElements(gl.TRIANGLES, numQuads * 6, gl.UNSIGNED_SHORT, 0);
	}
}

@:access(openfl.display.DisplayObject)
class BatchGLRenderer extends GLRenderer {
	function new(stage:Stage, gl:GLRenderContext) {
		super(stage, gl);
	}

	public override function render ():Void {
		gl.viewport (offsetX, offsetY, displayWidth, displayHeight);

		renderSession.painter = new Painter(renderSession);
		renderSession.allowSmoothing = (stage.quality != LOW);
		renderSession.upscaled = (displayMatrix.a != 1 || displayMatrix.d != 1);

		stage.__renderGL (renderSession);

		renderSession.painter.finishBatch();

		if (offsetX > 0 || offsetY > 0) {

			gl.clearColor (0, 0, 0, 1);
			gl.enable (gl.SCISSOR_TEST);

			if (offsetX > 0) {

				gl.scissor (0, 0, offsetX, height);
				gl.clear (gl.COLOR_BUFFER_BIT);

				gl.scissor (offsetX + displayWidth, 0, width, height);
				gl.clear (gl.COLOR_BUFFER_BIT);

			}

			if (offsetY > 0) {

				gl.scissor (0, 0, width, offsetY);
				gl.clear (gl.COLOR_BUFFER_BIT);

				gl.scissor (0, offsetY + displayHeight, width, height);
				gl.clear (gl.COLOR_BUFFER_BIT);

			}

			gl.disable (gl.SCISSOR_TEST);

		}

	}
}
