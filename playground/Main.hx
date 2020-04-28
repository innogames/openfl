import openfl.display.Sprite;

class Main extends Sprite {
	function new() {
		super();
	}

	static function main() {
		var app = new lime.app.Application();
		app.create({
			windows: [
				{
					element: js.Browser.document.getElementById("main"),
					background: 0x0E1E2D,
					allowHighDPI: true,
					resizable: true,
					depthBuffer: false,
					stencilBuffer: true
				},
			]
		});
		app.exec();

		var stage = app.stage;
		openfl.display.DisplayObject.__initStage = stage;
		stage.addChild(new Main());
	}
}
