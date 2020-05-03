package lime.ui;

import lime.app.Application;
import lime.app.Config;
import lime.app.Event;
import lime.graphics.Renderer;
import lime._backend.html5.HTML5Window as WindowBackend;

typedef CopyDataProvider = String->Void;

class Window {
	public var application(default, null):Application;
	public var config:WindowConfig;
	public var displayHeight(get, never):Int;
	public var displayWidth(get, never):Int;
	public var enableTextEvents(get, set):Bool;
	public var enableContextMenuEvents:Bool;
	public var fullscreen(get, set):Bool;
	public var height:Int;
	public var id(default, null):Int;
	public var onActivate = new Event<Void->Void>();
	public var onClose = new Event<Void->Void>();
	public var onDeactivate = new Event<Void->Void>();
	public var onDropFile = new Event<String->Void>();
	public var onEnter = new Event<Void->Void>();
	public var onFocusIn = new Event<Void->Void>();
	public var onFocusOut = new Event<Void->Void>();
	public var onFullscreen = new Event<Void->Void>();
	public var onKeyDown = new Event<KeyCode->KeyModifier->Void>();
	public var onKeyUp = new Event<KeyCode->KeyModifier->Void>();
	public var onLeave = new Event<Void->Void>();
	public var onMinimize = new Event<Void->Void>();
	public var onMouseDown = new Event<Float->Float->Int->Void>();
	public var onMouseMove = new Event<Float->Float->Void>();
	public var onMouseUp = new Event<Float->Float->Int->Void>();
	public var onMouseWheel = new Event<Int->Void>();
	public var onMove = new Event<Float->Float->Void>();
	public var onResize = new Event<Int->Int->Void>();
	public var onRestore = new Event<Void->Void>();
	public var onTextInput = new Event<String->Void>();
	public var onTextCopy = new Event<CopyDataProvider->Void>();
	public var onTextCut = new Event<CopyDataProvider->Void>();
	public var onTextPaste = new Event<String->Void>();
	public var renderer(default, null):Renderer;
	public var scale(default, null):Float;
	public var title(get, set):String;
	public var width:Int;

	@:noCompletion private var backend:WindowBackend;
	@:noCompletion private var __fullscreen:Bool;
	@:noCompletion private var __maximized:Bool;
	@:noCompletion private var __minimized:Bool;
	@:noCompletion private var __resizable:Bool;
	@:noCompletion private var __title:String;

	public function new(config:WindowConfig = null) {
		if (config == null)
			config = {};

		this.config = config;

		width = 0;
		height = 0;
		__fullscreen = false;
		scale = 1;
		__title = "";
		id = -1;

		if (Reflect.hasField(config, "width"))
			width = config.width;
		if (Reflect.hasField(config, "height"))
			height = config.height;
		if (Reflect.hasField(config, "resizable"))
			__resizable = config.resizable;
		if (Reflect.hasField(config, "title"))
			__title = config.title;

		backend = new WindowBackend(this);

		renderer = new Renderer(this);
	}

	@:access(openfl.display.Stage)
	@:access(openfl.display.LoaderInfo)
	public function create(application:Application):Void {
		this.application = application;

		backend.create(application);

		renderer.create();
	}

	// Get & Set Methods

	@:noCompletion inline function get_displayWidth():Int {
		return js.Browser.window.screen.width;
	}

	@:noCompletion inline function get_displayHeight():Int {
		return js.Browser.window.screen.height;
	}

	@:noCompletion private inline function get_enableTextEvents():Bool {
		return backend.getEnableTextEvents();
	}

	@:noCompletion private inline function set_enableTextEvents(value:Bool):Bool {
		return backend.setEnableTextEvents(value);
	}

	@:noCompletion private inline function get_fullscreen():Bool {
		return __fullscreen;
	}

	@:noCompletion private function set_fullscreen(value:Bool):Bool {
		return __fullscreen = backend.setFullscreen(value);
	}

	@:noCompletion private inline function get_title():String {
		return __title;
	}

	@:noCompletion private function set_title(value:String):String {
		return __title = backend.setTitle(value);
	}
}
