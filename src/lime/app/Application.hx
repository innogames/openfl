package lime.app;

import openfl.display.Stage;
import lime.graphics.Renderer;
import lime.system.System;
import lime.ui.Window;
import lime._backend.html5.HTML5Application as ApplicationBackend;

import openfl.display.LoaderInfo;
import openfl.display.Sprite;
import openfl._internal.Lib;

class Application {
	public static var current (default, null):Application;

	public var config (default, null):Config;
	
	/**
	 * The current frame rate (measured in frames-per-second) of the application.
	 *
	 * On some platforms, a frame rate of 60 or greater may imply vsync, which will
	 * perform more quickly on displays with a higher refresh rate
	**/
	public var frameRate (get, set):Float;
	
	public var stage (default, null):Stage;
	public var window (default, null):Window;
	public var renderer (default, null):Renderer;

	public var onExit = new Event<Int->Void> ();
	
	var backend:ApplicationBackend;
	
	
	public function new () {
		
		if (Application.current == null) {
			
			Application.current = this;
			
		}
		
		backend = new ApplicationBackend (this);

	}
	
	
	@:access(openfl.display.DisplayObject)
	@:access(openfl.display.LoaderInfo)
	public function create (config:Config):Void {
		this.config = config;

		var windowConfig = config.windows[0];

		var loaderInfo = LoaderInfo.create (null);
		if (windowConfig.parameters != null) {
			loaderInfo.parameters = windowConfig.parameters;
		}

		if (Lib.current == null) Lib.current = new Sprite ();
		Lib.current.__loaderInfo = loaderInfo;
		Lib.current.__loaderInfo.content = Lib.current;

		if (Reflect.hasField (config, "fps")) {
			
			frameRate = config.fps;
			
		}
		
		window = new Window (windowConfig);
		renderer = window.renderer; // TODO: remove this

		window.onClose.add (onWindowClose);
		window.create (this);

		stage = new Stage (window, Reflect.hasField (windowConfig, "background") ? windowConfig.background : 0xFFFFFF);
		
		if (Reflect.hasField (windowConfig, "resizable") && !windowConfig.resizable) {
			stage.__setLogicalSize (windowConfig.width, windowConfig.height);
		}

		stage.__create (this);
		
	}


	function onWindowClose () {
		window = null;
		renderer = null;
		System.exit (0);
	}
	
	
	public function exec () {
		
		Application.current = this;
		
		backend.exec ();
		
	}
	
	
	inline function get_frameRate ():Float {
		return backend.getFrameRate ();
	}
	

	inline function set_frameRate (value:Float):Float {
		return backend.setFrameRate (value);
	}
	
}
