import openfl.display.Sprite;

class Main extends Sprite {
	function new() {
		super();
	}

	static function main() {
		openfl.display.Stage.create(Main.new, {
			element: js.Browser.document.getElementById("main"),
			background: 0x0E1E2D,
			allowHighDPI: true,
			resizable: true,
			depthBuffer: false,
			stencilBuffer: true
		});
	}
}
