package openfl.display;

import openfl.display.ShaderParameter;

final class ShaderData {
	public var aAlpha:ShaderParameterAttrib;
	public var aPosition:ShaderParameterAttrib;
	public var aTexCoord:ShaderParameterAttrib;
	public var aColorMultipliers0:ShaderParameterAttrib;
	public var aColorMultipliers1:ShaderParameterAttrib;
	public var aColorMultipliers2:ShaderParameterAttrib;
	public var aColorMultipliers3:ShaderParameterAttrib;
	public var aColorOffsets:ShaderParameterAttrib;
	public var uImage0:ShaderParameterSampler;
	public var uMatrix:ShaderParameterMatrix4;
	public var uColorTransform:ShaderParameterBool;

	public function new() {}
}
