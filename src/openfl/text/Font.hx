package openfl.text;

import js.Browser;
import js.html.SpanElement;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.Log;

class Font {
	public var fontName(default, null):String;
	public var fontStyle(default, null):FontStyle;
	public var fontType(default, null):FontType;

	private static var __fontByName = new Map<String, Font>();
	private static var __registeredFonts = new Array<Font>();

	public function new(?name:String) {
		this.fontName = name;
	}

	public static function enumerateFonts(enumerateDeviceFonts:Bool = false):Array<Font> {
		return __registeredFonts;
	}

	public static function loadFromName(path:String):Future<Font> {
		return new Font().__loadFromName(path);
	}

	public static function registerFont(font:Class<Font>) {
		var instance = Type.createInstance(font, []);

		if (instance != null) {
			__registeredFonts.push(instance);
			__fontByName[instance.fontName] = instance;
		}
	}

	private function __loadFromName(name:String):Future<Font> {
		var promise = new Promise<Font>();

		this.fontName = name;

		var ua = Browser.navigator.userAgent.toLowerCase();
		var isSafari = (ua.indexOf(" safari/") >= 0 && ua.indexOf(" chrome/") < 0);

		if (!isSafari && Browser.document.fonts != null && Browser.document.fonts.load != null) {
			Browser.document.fonts.load("1em '" + name + "'").then(function(_) {
				promise.complete(this);
			}, function(_) {
				Log.warn("Could not load web font \"" + name + "\"");
				promise.complete(this);
			});
		} else {
			var node1 = __measureFontNode("'" + name + "', sans-serif");
			var node2 = __measureFontNode("'" + name + "', serif");

			var width1 = node1.offsetWidth;
			var width2 = node2.offsetWidth;

			var interval = -1;
			var timeout = 3000;
			var intervalLength = 50;
			var intervalCount = 0;
			var loaded, timeExpired;

			function checkFont() {
				intervalCount++;

				loaded = (node1.offsetWidth != width1 || node2.offsetWidth != width2);
				timeExpired = (intervalCount * intervalLength >= timeout);

				if (loaded || timeExpired) {
					Browser.window.clearInterval(interval);
					node1.parentNode.removeChild(node1);
					node2.parentNode.removeChild(node2);
					node1 = null;
					node2 = null;

					if (timeExpired) {
						Log.warn("Could not load web font \"" + name + "\"");
					}

					promise.complete(this);
				}
			}

			interval = Browser.window.setInterval(checkFont, intervalLength);
		}

		return promise.future;
	}

	private static function __measureFontNode(fontFamily:String):SpanElement {
		var node:SpanElement = cast Browser.document.createElement("span");
		node.setAttribute("aria-hidden", "true");
		var text = Browser.document.createTextNode("BESbswy");
		node.appendChild(text);
		var style = node.style;
		style.display = "block";
		style.position = "absolute";
		style.top = "-9999px";
		style.left = "-9999px";
		style.fontSize = "300px";
		style.width = "auto";
		style.height = "auto";
		style.lineHeight = "normal";
		style.margin = "0";
		style.padding = "0";
		style.fontVariant = "normal";
		style.whiteSpace = "nowrap";
		style.fontFamily = fontFamily;
		Browser.document.body.appendChild(node);
		return node;
	}
}
