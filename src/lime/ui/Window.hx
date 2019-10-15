package lime.ui;


import lime.app.Application;
import lime.app.Config;
import lime.app.Event;
import lime.graphics.Image;
import lime.graphics.Renderer;
import lime.system.Display;
import lime.system.DisplayMode;

import openfl.display.Stage;

typedef CopyDataProvider = String->Void;


#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class Window {
	
	
	public var application (default, null):Application;
	public var borderless (get, set):Bool;
	public var config:WindowConfig;
	public var display (get, null):Display;
	public var displayMode (get, set):DisplayMode;
	public var enableTextEvents (get, set):Bool;
	public var enableContextMenuEvents:Bool;
	public var fullscreen (get, set):Bool;
	public var height (get, set):Int;
	public var id (default, null):Int;
	public var maximized (get, set):Bool;
	public var minimized (get, set):Bool;
	public var onActivate = new Event<Void->Void> ();
	public var onClose = new Event<Void->Void> ();
	public var onCreate = new Event<Void->Void> ();
	public var onDeactivate = new Event<Void->Void> ();
	public var onDropFile = new Event<String->Void> ();
	public var onEnter = new Event<Void->Void> ();
	public var onFocusIn = new Event<Void->Void> ();
	public var onFocusOut = new Event<Void->Void> ();
	public var onFullscreen = new Event<Void->Void> ();
	public var onKeyDown = new Event<KeyCode->KeyModifier->Void> ();
	public var onKeyUp = new Event<KeyCode->KeyModifier->Void> ();
	public var onLeave = new Event<Void->Void> ();
	public var onMinimize = new Event<Void->Void> ();
	public var onMouseDown = new Event<Float->Float->Int->Void> ();
	public var onMouseMove = new Event<Float->Float->Void> ();
	public var onMouseMoveRelative = new Event<Float->Float->Void> ();
	public var onMouseUp = new Event<Float->Float->Int->Void> ();
	public var onMouseWheel = new Event<Int->Void> ();
	public var onMove = new Event<Float->Float->Void> ();
	public var onResize = new Event<Int->Int->Void> ();
	public var onRestore = new Event<Void->Void> ();
	public var onTextEdit = new Event<String->Int->Int->Void> ();
	public var onTextInput = new Event<String->Void> ();
	public var onTextCopy = new Event<CopyDataProvider->Void> ();
	public var onTextCut = new Event<CopyDataProvider->Void> ();
	public var onTextPaste = new Event<String->Void> ();
	public var renderer:Renderer;
	public var resizable (get, set):Bool;
	public var scale (get, null):Float;
	public var stage:Stage;
	public var title (get, set):String;
	public var width (get, set):Int;
	public var x (get, set):Int;
	public var y (get, set):Int;
	
	@:noCompletion private var backend:WindowBackend;
	@:noCompletion private var __borderless:Bool;
	@:noCompletion private var __fullscreen:Bool;
	@:noCompletion private var __height:Int;
	@:noCompletion private var __maximized:Bool;
	@:noCompletion private var __minimized:Bool;
	@:noCompletion private var __resizable:Bool;
	@:noCompletion private var __scale:Float;
	@:noCompletion private var __title:String;
	@:noCompletion private var __width:Int;
	@:noCompletion private var __x:Int;
	@:noCompletion private var __y:Int;
	
	
	public function new (config:WindowConfig = null) {
		
		this.config = config;
		
		__width = 0;
		__height = 0;
		__fullscreen = false;
		__scale = 1;
		__x = 0;
		__y = 0;
		__title = "";
		id = -1;
		
		if (config != null) {
			
			if (Reflect.hasField (config, "width")) __width = config.width;
			if (Reflect.hasField (config, "height")) __height = config.height;
			if (Reflect.hasField (config, "x")) __x = config.x;
			if (Reflect.hasField (config, "y")) __y = config.y;
			#if !web
			if (Reflect.hasField (config, "fullscreen")) __fullscreen = config.fullscreen;
			#end
			if (Reflect.hasField (config, "borderless")) __borderless = config.borderless;
			if (Reflect.hasField (config, "resizable")) __resizable = config.resizable;
			if (Reflect.hasField (config, "title")) __title = config.title;
			
		}
		
		backend = new WindowBackend (this);
		
	}
	
	
	public function alert (message:String = null, title:String = null):Void {
		
		backend.alert (message, title);
		
	}
	
	
	public function close ():Void {
		
		backend.close ();
		
	}
	
	@:access(openfl.display.Stage)
	@:access(openfl.display.LoaderInfo)
	public function create (application:Application):Void {
		
		this.application = application;
		
		if (config == null) config = {};
		backend.create (application);
		
		if (renderer != null) {
			
			renderer.create ();
			
		}
		
		stage = new Stage (this, Reflect.hasField (config, "background") ? config.background : 0xFFFFFF);
		
		if (Reflect.hasField (config, "parameters")) {
			
			stage.loaderInfo.parameters = config.parameters;
			
		}
		
		if (Reflect.hasField (config, "resizable") && !config.resizable) {
			
			stage.__setLogicalSize (config.width, config.height);
			
		}
		
		application.addModule (stage);
		
	}
	
	
	public function focus ():Void {
		
		backend.focus ();
		
	}
	
	
	public function move (x:Int, y:Int):Void {
		
		backend.move (x, y);
		
		__x = x;
		__y = y;
		
	}
	
	
	public function resize (width:Int, height:Int):Void {
		
		backend.resize (width, height);
		
		__width = width;
		__height = height;
		
	}
	
	
	public function setIcon (image:Image):Void {
		
		if (image == null) {
			
			return;
			
		}
		
		backend.setIcon (image);
		
	}
	
	
	public function toString ():String {
		
		return "[object Window]";
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	@:noCompletion private function get_display ():Display {
		
		return backend.getDisplay ();
		
	}
	
	
	@:noCompletion private function get_displayMode ():DisplayMode {
		
		return backend.getDisplayMode ();
		
	}
	
	
	@:noCompletion private function set_displayMode (value:DisplayMode):DisplayMode {
		
		return backend.setDisplayMode (value);
		
	}
	
	
	@:noCompletion private inline function get_borderless ():Bool {
		
		return __borderless;
		
	}
	
	
	@:noCompletion private function set_borderless (value:Bool):Bool {
		
		return __borderless = backend.setBorderless (value);
		
	}
	
	
	@:noCompletion private inline function get_enableTextEvents ():Bool {
		
		return backend.getEnableTextEvents ();
		
	}
	
	
	@:noCompletion private inline function set_enableTextEvents (value:Bool):Bool {
		
		return backend.setEnableTextEvents (value);
		
	}


	@:noCompletion private inline function get_fullscreen ():Bool {
		
		return __fullscreen;
		
	}
	
	
	@:noCompletion private function set_fullscreen (value:Bool):Bool {
		
		return __fullscreen = backend.setFullscreen (value);
		
	}
	
	
	@:noCompletion private inline function get_height ():Int {
		
		return __height;
		
	}
	
	
	@:noCompletion private function set_height (value:Int):Int {
		
		resize (__width, value);
		return __height;
		
	}
	
	
	@:noCompletion private inline function get_maximized ():Bool {
		
		return __maximized;
		
	}
	
	
	@:noCompletion private inline function set_maximized (value:Bool):Bool {
		
		__minimized = false;
		return __maximized = backend.setMaximized (value);
		
	}
	
	
	@:noCompletion private inline function get_minimized ():Bool {
		
		return __minimized;
		
	}
	
	
	@:noCompletion private function set_minimized (value:Bool):Bool {
		
		__maximized = false;
		return __minimized = backend.setMinimized (value);
		
	}
	
	
	@:noCompletion private inline function get_resizable ():Bool {
		
		return __resizable;
		
	}
	
	
	@:noCompletion private function set_resizable (value:Bool):Bool {
		
		__resizable = backend.setResizable (value);
		return __resizable;
		
	}
	
	
	@:noCompletion private inline function get_scale ():Float {
		
		return __scale;
		
	}
	
	
	@:noCompletion private inline function get_title ():String {
		
		return __title;
		
	}
	
	
	@:noCompletion private function set_title (value:String):String {
		
		return __title = backend.setTitle (value);
		
	}
	
	
	@:noCompletion private inline function get_width ():Int {
		
		return __width;
		
	}
	
	
	@:noCompletion private function set_width (value:Int):Int {
		
		resize (value, __height);
		return __width;
		
	}
	
	
	@:noCompletion private inline function get_x ():Int {
		
		return __x;
		
	}
	
	
	@:noCompletion private function set_x (value:Int):Int {
		
		move (value, __y);
		return __x;
		
	}
	
	
	@:noCompletion private inline function get_y ():Int {
		
		return __y;
		
	}
	
	
	@:noCompletion private function set_y (value:Int):Int {
		
		move (__x, value);
		return __y;
		
	}
	
	
}


#if (js && html5)
@:noCompletion private typedef WindowBackend = lime._backend.html5.HTML5Window;
#end
