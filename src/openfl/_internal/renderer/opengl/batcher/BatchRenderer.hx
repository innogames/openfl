package openfl._internal.renderer.opengl.batcher;

import haxe.ds.Vector;

import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import openfl.geom.Rectangle;
import openfl._internal.renderer.opengl.GLBlendModeManager;
import openfl._internal.renderer.opengl.GLShaderManager;
import openfl._internal.renderer.opengl.batcher.BitHacks.*;
import openfl._internal.renderer.opengl.batcher.Quad;

#if gl_stats
import openfl._internal.renderer.opengl.stats.GLStats;
import openfl._internal.renderer.opengl.stats.DrawCallContext;
#end

// inspired by pixi.js SpriteRenderer
@:expose("batcher")
class BatchRenderer {
	static var skipRendering = false;
	
	var gl:GLRenderContext;
	var instancedRendering:InstancedRendering;
	var blendModeManager:GLBlendModeManager;
	var shaderManager:GLShaderManager;
	var maxQuads:Int;
	var maxTextures:Int;

	var shader:MultiTextureShader;
	var vertexBuffer:GLBuffer;
	var quadBuffer:GLBuffer;
	var quadBufferData:Float32Array;

	var groups:Vector<RenderGroup>;
	var boundTextures:Vector<TextureData>;

	var currentBlendMode = BlendMode.NORMAL;
	var currentTexture:TextureData;
	var currentQuadIndex = 0;
	var currentGroup:RenderGroup;
	var currentGroupCount = 0;

	var tick = 0;
	var textureTick = 0;

	public var projectionMatrix:Float32Array;

	var emptyTexture:GLTexture;

	final viewport = new Rectangle();

	public function new(gl:GLRenderContext, instancedRendering:InstancedRendering, blendModeManager:GLBlendModeManager, shaderManager:GLShaderManager, maxQuads:Int) {
		this.gl = gl;
		this.instancedRendering = instancedRendering;
		this.blendModeManager = blendModeManager;
		this.shaderManager = shaderManager;
		this.maxQuads = maxQuads;

		// determine amount of textures we can draw at once and generate a shader for that
		shader = new MultiTextureShader(gl, instancedRendering);
		maxTextures = shader.maxTextures;

		emptyTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, emptyTexture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, 1, 1, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);

		// a singleton vector we use to track texture binding when rendering
		boundTextures = new Vector(maxTextures);

		// preallocate block of memory for the quad data buffer
		quadBufferData = new Float32Array(maxQuads * MultiTextureShader.floatsPerQuad);

		// create the quad buffer for further uploading
		quadBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, quadBufferData.byteLength, quadBufferData, gl.STREAM_DRAW);

		// preallocate a static vertex buffer for quad instances,
		// consisting of one vec4 per vertex used to extract actual
		// position values from the quad buffer
		var vertices = new Float32Array([
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		]);
		vertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, vertices.byteLength, vertices, gl.STATIC_DRAW);

		// preallocate render group objects for any number of quads (worst case - 1 group per quad)
		groups = new Vector(maxQuads);
		for (i in 0...maxQuads) {
			groups[i] = new RenderGroup();
		}

		startNextGroup();
	}

	inline function finishCurrentGroup() {
		currentGroup.size = currentQuadIndex - currentGroup.start;
	}

	inline function startNextGroup() {
		currentGroup = groups[currentGroupCount];
		currentGroup.textureCount = 0;
		currentGroup.start = currentQuadIndex;
		currentGroup.blendMode = currentBlendMode;
		// we always increase the tick when staring a new render group, so all textures become "disabled" and need to be processed
		tick++;
		currentGroupCount++;
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
		if (skipRendering) return;
		
		if (!isQuadWithinViewport(quad)) {
			#if gl_stats
				GLStats.skippedQuadCounter.increment();
			#end
			return;
		}

		if (currentQuadIndex >= maxQuads) {
			flush();
		}

		var nextTexture = quad.texture.data;

		if (currentBlendMode != quad.blendMode) {
			currentBlendMode = quad.blendMode;
			currentTexture = null;

			finishCurrentGroup();
			startNextGroup();
		}

		// if the texture was used in the current group (ticks are equal), but the smoothing mode has changed
		// we gotta break the batch, because we can't render the same texture with different smoothing in a single batch
		// TODO: we can in WebGL2 using Sampler objects
		if (nextTexture.enabledTick == tick && nextTexture.lastSmoothing != quad.smoothing) {
			currentTexture = null;

			finishCurrentGroup();
			startNextGroup();
		}

		// if the texture has changed - we need to either pack it into the current render group or create the next one
		// and since on the first iteration the `currentTexture` is null, it's always "changed"
		if (currentTexture != nextTexture) {
			currentTexture = nextTexture;

			// if the texture's tick and current tick are equal, that means
			// that the texture was already enabled in the current group
			// and we don't need to do anything, otherwise...
			if (currentTexture.enabledTick != tick) {

				// if the current group is already full of textures, finish it and start a new one
				if (currentGroup.textureCount == maxTextures) {
					finishCurrentGroup();
					startNextGroup();
				}

				// if the texture hasn't yet been bound to a texture unit this render, we need to choose one
				if (nextTexture.textureUnitId == -1) {
					// iterate over possible texture "slots"
					for (i in 0...maxTextures) {
						// we use "texture tick" for calculating texture unit,
						// so we always start checking with the next texture unit,
						// relative to previous binding
						var textureUnit = (i + textureTick) % maxTextures;

						// if there's no bound texture in this slot, or that texture
						// wasn't used in this group (ticks are different), we can use this slot!
						var boundTexture = boundTextures[textureUnit];
						if (boundTexture == null || boundTexture.enabledTick != tick) {
							// if there was a texture in this slot - unbind it, since we're replacing it
							if (boundTexture != null) {
								boundTexture.textureUnitId = -1;
							}

							// assign this texture to the texture unit
							nextTexture.textureUnitId = textureUnit;
							boundTextures[textureUnit] = nextTexture;

							// increase the tick so next time we'll start looking directly from the next texture unit
							textureTick++;

							// and we're done here
							break;
						}
					}
					if (nextTexture.textureUnitId == -1) {
						throw "Unable to find free texture unit for the batch render group! This should NOT happen!";
					}
				}

				// mark the texture as enabled in this group
				nextTexture.enabledTick = tick;
				nextTexture.lastSmoothing = quad.smoothing;
				// add the texture to the group textures array
				currentGroup.textures[currentGroup.textureCount] = nextTexture;
				// save the texture unit number separately as it can change when processing next group
				currentGroup.textureUnits[currentGroup.textureCount] = nextTexture.textureUnitId;
				currentGroup.textureSmoothing[currentGroup.textureCount] = quad.smoothing;
				currentGroup.textureCount++;
			}
		}

		// fill the quad buffer
		var vertexData = quad.vertexData;
		var uvs = quad.texture.uvs;
		var textureUnitId = nextTexture.textureUnitId;
		var alpha = quad.alpha;
		var pma = quad.texture.premultipliedAlpha;
		var colorTransform = quad.colorTransform;

		// trace('Group $currentGroupCount uses texture $textureUnitId');

		var quadBufferData = this.quadBufferData;
		var offset = currentQuadIndex * MultiTextureShader.floatsPerQuad;
		
		inline function setVertex(i:Int, target:Int) {
			// x
			quadBufferData[offset + target] = vertexData[i * 2];
			// y
			quadBufferData[offset + 4 + target] = vertexData[i * 2 + 1];
			// u
			quadBufferData[offset + 8 + target] = uvs[i * 2];
			// v
			quadBufferData[offset + 12 + target] = uvs[i * 2 + 1];
		}
		setVertex(0, 0);
		setVertex(1, 1);
		setVertex(2, 3); // the Z order
		setVertex(3, 2); // for triangle strip

		quadBufferData[offset + 16] = textureUnitId;

		if (colorTransform != null) {
			quadBufferData[offset + 17] = colorTransform.redOffset / 255;
			quadBufferData[offset + 18] = colorTransform.greenOffset / 255;
			quadBufferData[offset + 19] = colorTransform.blueOffset / 255;
			quadBufferData[offset + 20] = (colorTransform.alphaOffset / 255) * alpha;

			quadBufferData[offset + 21] = colorTransform.redMultiplier;
			quadBufferData[offset + 22] = colorTransform.greenMultiplier;
			quadBufferData[offset + 23] = colorTransform.blueMultiplier;
			quadBufferData[offset + 24] = colorTransform.alphaMultiplier * alpha;
		} else {
			quadBufferData[offset + 17] = 0;
			quadBufferData[offset + 18] = 0;
			quadBufferData[offset + 19] = 0;
			quadBufferData[offset + 20] = 0;

			quadBufferData[offset + 21] = 1;
			quadBufferData[offset + 22] = 1;
			quadBufferData[offset + 23] = 1;
			quadBufferData[offset + 24] = alpha;
		}

		quadBufferData[offset + 25] = pma ? 1 : 0;

		currentQuadIndex++;
		#if gl_stats
			GLStats.quadCounter.increment();
		#end
	}

	/** render all the quads we collected **/
	public function flush() {
		if (currentQuadIndex == 0) {
			return;
		}

		// finish the current group
		finishCurrentGroup();

		// use local vars to save some field access
		var gl = this.gl;
		var blendModeManager = this.blendModeManager;
		var boundTextures = this.boundTextures;
		var groups = this.groups;

		shader.enable(projectionMatrix);

		// setup the vertex buffer
		gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
		gl.vertexAttribPointer(shader.aExtractor, 4, gl.FLOAT, false, 4 * Float32Array.BYTES_PER_ELEMENT, 0);

		// upload quad data
		gl.bindBuffer(gl.ARRAY_BUFFER, quadBuffer);
		var subArray = quadBufferData.subarray(0, currentQuadIndex * MultiTextureShader.floatsPerQuad);
		gl.bufferSubData(gl.ARRAY_BUFFER, 0, subArray.byteLength, subArray);

		for (i in 0...maxTextures) {
			gl.activeTexture(gl.TEXTURE0 + i);
			gl.bindTexture(gl.TEXTURE_2D, emptyTexture);
		}

		var lastBlendMode = null;

		var stride = MultiTextureShader.floatsPerQuad * Float32Array.BYTES_PER_ELEMENT;
		var offset = 0;
		
		// iterate over groups and render them
		for (i in 0...currentGroupCount) {
			var group = groups[i];
			if (group.size == 0) {
				// TODO: don't even create empty groups (can happen when staring drawing with a non-NORMAL blendmode)
				continue;
			}
			// trace('Rendering group ${i + 1} (${group.size})');

			// bind this group's textures
			for (i in 0...group.textureCount) {
				var currentTexture = group.textures[i];
				// trace('Activating texture at ${group.textureUnits[i]}: ${currentTexture.glTexture}');
				gl.activeTexture(gl.TEXTURE0 + group.textureUnits[i]);
				gl.bindTexture(gl.TEXTURE_2D, currentTexture.glTexture);

				if (group.textureSmoothing[i]) {
					gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
				} else {
					gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
					gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				}

				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
				gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

				currentTexture.textureUnitId = -1; // clear the binding for subsequent flush calls
			}

			// apply the blend mode if changed
			if (group.blendMode != lastBlendMode) {
				lastBlendMode = group.blendMode;
				lastBlendMode.apply(gl);
			}

			// set vertex attribute pointers to the start of the group inside the vertex data
			gl.vertexAttribPointer(shader.aX,                  4, gl.FLOAT, false, stride, offset);
			gl.vertexAttribPointer(shader.aY,                  4, gl.FLOAT, false, stride, offset + 4 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aU,                  4, gl.FLOAT, false, stride, offset + 8 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aV,                  4, gl.FLOAT, false, stride, offset + 12 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aTextureId,          1, gl.FLOAT, false, stride, offset + 16 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aColorOffset,        4, gl.FLOAT, false, stride, offset + 17 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aColorMultiplier,    4, gl.FLOAT, false, stride, offset + 21 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.aPremultipliedAlpha, 1, gl.FLOAT, false, stride, offset + 25 * Float32Array.BYTES_PER_ELEMENT);

			// draw this group's slice of vertices
			instancedRendering.drawArraysInstanced(gl.TRIANGLE_STRIP, 0, 4, group.size);
			
			offset += group.size * stride;

			#if gl_stats
				GLStats.incrementDrawCall (DrawCallContext.STAGE);
			#end
		}
		
		shader.disable();

		// disable the current OpenFL shader so it'll be re-enabled properly on next non-batched openfl render
		// this is needed because we don't use ShaderManager to set our shader. Ideally we should do that, but
		// this will requires some rework for the whole OpenFL shader system, which we'll do when we'll fork away for good
		shaderManager.setShader(null);
		blendModeManager.setBlendMode(NORMAL);

		for (i in 0...maxTextures) {
			boundTextures[i] = null;
		}
		currentTexture = null;
		currentQuadIndex = 0;
		currentBlendMode = BlendMode.NORMAL;
		currentGroupCount = 0;
		startNextGroup();
	}
}

private class RenderGroup {
	public var textures = new Array<TextureData>();
	public var textureUnits = new Array<Int>();
	public var textureSmoothing = new Array<Bool>();
	public var textureCount = 0;
	public var size = 0;
	public var start = 0;
	public var blendMode:BlendMode;
	public function new() {}
}
