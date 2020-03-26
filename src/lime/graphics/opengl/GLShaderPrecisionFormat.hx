package lime.graphics.opengl;

#if (js && html5)
typedef GLShaderPrecisionFormat = js.html.webgl.ShaderPrecisionFormat;
#else
typedef GLShaderPrecisionFormat = {
	rangeMin:Int,
	rangeMax:Int,
	precision:Int
}
#end
