package openfl.text;

import openfl.events.EventDispatcher;
import openfl.utils.Object;

class StyleSheet extends EventDispatcher {
	public var styleNames(get, never):Array<String>;

	public function new() {
		super(this);
	}

	private function get_styleNames():Array<String> {
		// stub
		return null;
	}

	public function clear():Void {
		// stub
	}

	public function getStyle(styleName:String):Object {
		// stub
		return null;
	}

	public function parseCSS(CSSText:String):Void {
		// stub
	}

	public function setStyle(styleName:String, styleObject:Object):Void {
		// stub
	}

	public function transform(formatObject:Object):TextFormat {
		// stub
		return null;
	}
}
