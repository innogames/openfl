package openfl.text;

import openfl.events.EventDispatcher;
import openfl.utils.Object;

class StyleSheet extends EventDispatcher {
	public var styleNames(get, never):Array<String>;

	private var __styles = new Map<String, Object>();

	public function new() {
		super(this);
	}

	private function get_styleNames():Array<String> {
		return [for (n in __styles.keys()) n];
	}

	public function clear():Void {
		__styles.clear();
	}

	public function getStyle(styleName:String):Object {
		var styleObject = __styles[styleName];
		if (styleObject != null) {
			return styleObject; // TODO: clone!
		}
		return null;
	}

	public function parseCSS(CSSText:String):Void {
		// stub
	}

	public function setStyle(styleName:String, styleObject:Object):Void {
		if (styleObject != null) {
			__styles[styleName] = styleObject; // TODO: clone!
		} else {
			__styles.remove(styleName);
		}
	}

	public function transform(formatObject:Object):TextFormat {
		// stub
		return null;
	}
}
