package lime.graphics.opengl;

#if (js && html5)
@:native("WebGLSync")
extern class GLSync {}
#else
typedef GLSync = Dynamic;
#end
