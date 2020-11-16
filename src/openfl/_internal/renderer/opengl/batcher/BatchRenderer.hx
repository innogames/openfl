package openfl._internal.renderer.opengl.batcher;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import openfl._internal.renderer.opengl.GLBlendModeManager;
import openfl._internal.renderer.opengl.GLShaderManager;
import openfl._internal.renderer.opengl.batcher.Quad;
import openfl.geom.Rectangle;
#if gl_stats
import openfl._internal.renderer.opengl.stats.DrawCallContext;
import openfl._internal.renderer.opengl.stats.GLStats;
#end

// inspired by pixi.js SpriteRenderer
class BatchRenderer {
	var gl:GLRenderContext;
	var blendModeManager:GLBlendModeManager;
	var shaderManager:GLShaderManager;

	var shader:MultiTextureShader;
	var indexBuffer:GLBuffer;
	var vertexBuffer:GLBuffer;
	var vertexBufferData:Float32Array;

	public var projectionMatrix:Float32Array;

	final viewport = new Rectangle();

	static inline var floatsPerQuad = MultiTextureShader.floatsPerVertex * 4;

	public function new(gl:GLRenderContext, blendModeManager:GLBlendModeManager, shaderManager:GLShaderManager, _:Int) {
		this.gl = gl;
		this.blendModeManager = blendModeManager;
		this.shaderManager = shaderManager;

		// determine amount of textures we can draw at once and generate a shader for that
		shader = new MultiTextureShader(gl);

		// preallocate block of memory for the vertex buffer
		vertexBufferData = new Float32Array(floatsPerQuad);

		// create the vertex buffer for further uploading
		vertexBuffer = gl.createBuffer();
		gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(GL.ARRAY_BUFFER, vertexBufferData, GL.STREAM_DRAW);

		// preallocate a static index buffer for rendering any number of quads
		var indices = createIndicesForQuads(1);
		indexBuffer = gl.createBuffer();
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
		gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
	}

	public function flipVertical() {
		shader.positionScale[1] = -1;
	}

	public function unflipVertical() {
		shader.positionScale[1] = 1;
	}

	public inline function setViewport(x, y, w, h) {
		viewport.setTo(x, y, w, h);
	}

	inline function isQuadWithinViewport(quad:Quad):Bool {
		var x0 = quad.vertexData[0];
		var y0 = quad.vertexData[1];
		var x1 = quad.vertexData[4];
		var y1 = quad.vertexData[5];
		var left, right, top, bottom;
		if (x0 > x1) {
			left = x1;
			right = x0;
		} else {
			left = x0;
			right = x1;
		}
		if (y0 > y1) {
			top = y1;
			bottom = y0;
		} else {
			top = y0;
			bottom = y1;
		}
		var rect = viewport;
		return (right >= rect.x && bottom >= rect.y && left <= rect.right && top <= rect.bottom);
	}

	/** schedule quad for rendering **/
	public function render(quad:Quad) {
		if (!isQuadWithinViewport(quad)) {
			#if gl_stats
			GLStats.skippedQuadCounter.increment();
			#end
			return;
		}

		// fill the vertex buffer with vertex and texture coordinates, as well as the texture id
		var vertexData = quad.vertexData;
		var uvs = quad.texture.uvs;
		var alpha = quad.alpha;
		var pma = quad.texture.premultipliedAlpha;
		var colorTransform = quad.colorTransform;
		var vertexBufferData = this.vertexBufferData;

		// trace('Group $currentGroupCount uses texture $textureUnitId');

		inline function setVertex(i) {
			var offset = i * MultiTextureShader.floatsPerVertex;
			vertexBufferData[offset + 0] = vertexData[i * 2 + 0];
			vertexBufferData[offset + 1] = vertexData[i * 2 + 1];

			vertexBufferData[offset + 2] = uvs[i * 2 + 0];
			vertexBufferData[offset + 3] = uvs[i * 2 + 1];

			if (colorTransform != null) {
				vertexBufferData[offset + 4] = colorTransform.redOffset / 255;
				vertexBufferData[offset + 5] = colorTransform.greenOffset / 255;
				vertexBufferData[offset + 6] = colorTransform.blueOffset / 255;
				vertexBufferData[offset + 7] = (colorTransform.alphaOffset / 255) * alpha;

				vertexBufferData[offset + 8] = colorTransform.redMultiplier;
				vertexBufferData[offset + 9] = colorTransform.greenMultiplier;
				vertexBufferData[offset + 10] = colorTransform.blueMultiplier;
				vertexBufferData[offset + 11] = colorTransform.alphaMultiplier * alpha;
			} else {
				vertexBufferData[offset + 4] = 0;
				vertexBufferData[offset + 5] = 0;
				vertexBufferData[offset + 6] = 0;
				vertexBufferData[offset + 7] = 0;

				vertexBufferData[offset + 8] = 1;
				vertexBufferData[offset + 9] = 1;
				vertexBufferData[offset + 10] = 1;
				vertexBufferData[offset + 11] = alpha;
			}

			vertexBufferData[offset + 12] = pma ? 1 : 0;
		}

		setVertex(0);
		setVertex(1);
		setVertex(2);
		setVertex(3);

		shader.enable(projectionMatrix);

		// bind the index buffer
		gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);

		// upload vertex data and setup attribute pointers
		gl.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(GL.ARRAY_BUFFER, vertexBufferData, GL.STREAM_DRAW);

		var stride = MultiTextureShader.floatsPerVertex * Float32Array.BYTES_PER_ELEMENT;
		gl.vertexAttribPointer(shader.aVertexPosition, 2, GL.FLOAT, false, stride, 0);
		gl.vertexAttribPointer(shader.aTextureCoord, 2, GL.FLOAT, false, stride, 2 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.aColorOffset, 4, GL.FLOAT, false, stride, 4 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.aColorMultiplier, 4, GL.FLOAT, false, stride, 8 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.aPremultipliedAlpha, 1, GL.FLOAT, false, stride, 12 * Float32Array.BYTES_PER_ELEMENT);

		gl.activeTexture(GL.TEXTURE0);
		gl.bindTexture(GL.TEXTURE_2D, quad.texture.data.glTexture);

		if (quad.smoothing) {
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
		} else {
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
			gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
		}

		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
		gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);

		quad.blendMode.apply(gl);

		gl.drawElements(GL.TRIANGLES, 6, GL.UNSIGNED_SHORT, 0);

		// disable the current OpenFL shader so it'll be re-enabled properly on next non-batched openfl render
		// this is needed because we don't use ShaderManager to set our shader. Ideally we should do that, but
		// this will requires some rework for the whole OpenFL shader system, which we'll do when we'll fork away for good
		shaderManager.setShader(null);
		blendModeManager.setBlendMode(NORMAL);

		#if gl_stats
		GLStats.quadCounter.increment();
		GLStats.incrementDrawCall(DrawCallContext.STAGE);
		#end
	}

	/** render all the quads we collected **/
	public inline function flush() {}

	/** creates an pre-filled index buffer data for rendering triangles **/
	static function createIndicesForQuads(numQuads:Int):UInt16Array {
		var totalIndices = numQuads * 3 * 2; // 2 triangles of 3 verties per quad
		var indices = new UInt16Array(totalIndices);
		var i = 0, j = 0;
		while (i < totalIndices) {
			indices[i + 0] = j + 0;
			indices[i + 1] = j + 1;
			indices[i + 2] = j + 2;
			indices[i + 3] = j + 0;
			indices[i + 4] = j + 2;
			indices[i + 5] = j + 3;
			i += 6;
			j += 4;
		}
		return indices;
	}
}
