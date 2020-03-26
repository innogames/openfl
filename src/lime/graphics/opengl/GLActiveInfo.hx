package lime.graphics.opengl;

#if (js && html5)
typedef GLActiveInfo = js.html.webgl.ActiveInfo;
#else
typedef GLActiveInfo = {
	size:Int,
	type:Int,
	name:String
}
#end
