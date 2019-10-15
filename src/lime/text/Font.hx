package lime.text;


import haxe.io.Bytes;
import lime.app.Future;
import lime.app.Promise;
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.math.Vector2;
import lime.system.System;
import lime.utils.Log;
import lime.utils.UInt8Array;

#if (js && html5)
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.SpanElement;
import js.Browser;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(lime.text.Glyph)
class Font {
	
	
	public var name (default, null):String;
	public var src:Dynamic;
	
	@:noCompletion private var __fontID:String;
	@:noCompletion private var __fontPath:String;
	
	
	public function new (name:String = null) {
		
		this.name = name;
		
	}
	
	
	public static function loadFromName (path:String):Future<Font> {
		
		#if (js && html5)
		
		var font = new Font ();
		return font.__loadFromName (path);
		
		#else
		
		return cast Future.withError ("");
		
		#end
		
	}
	
	
	private function __loadFromName (name:String):Future<Font> {
		
		var promise = new Promise<Font> ();
		
		#if (js && html5)
		
		this.name = name;
		
		var ua = Browser.navigator.userAgent.toLowerCase();
		var isSafari = (ua.indexOf(" safari/") >= 0 && ua.indexOf(" chrome/") < 0);
		
		if (!isSafari && Browser.document.fonts != null && Browser.document.fonts.load != null) {
			
			Browser.document.fonts.load ("1em '" + name + "'").then (function (_) {
				
				promise.complete (this);
				
			}, function (_) {
				
				Log.warn ("Could not load web font \"" + name + "\"");
				promise.complete (this);
				
			});
			
		} else {
			
			var node1 = __measureFontNode ("'" + name + "', sans-serif");
			var node2 = __measureFontNode ("'" + name + "', serif");
			
			var width1 = node1.offsetWidth;
			var width2 = node2.offsetWidth;
			
			var interval = -1;
			var timeout = 3000;
			var intervalLength = 50;
			var intervalCount = 0;
			var loaded, timeExpired;
			
			var checkFont = function () {
				
				intervalCount++;
				
				loaded = (node1.offsetWidth != width1 || node2.offsetWidth != width2);
				timeExpired = (intervalCount * intervalLength >= timeout);
				
				if (loaded || timeExpired) {
					
					Browser.window.clearInterval (interval);
					node1.parentNode.removeChild (node1);
					node2.parentNode.removeChild (node2);
					node1 = null;
					node2 = null;
					
					if (timeExpired) {
						
						Log.warn ("Could not load web font \"" + name + "\"");
						
					}
					
					promise.complete (this);
					
				}
				
			}
			
			interval = Browser.window.setInterval (checkFont, intervalLength);
			
		}
		
		#else
		
		promise.error ("");
		
		#end
		
		return promise.future;
		
	}
	
	
	#if (js && html5)
	private static function __measureFontNode (fontFamily:String):SpanElement {
		
		var node:SpanElement = cast Browser.document.createElement ("span");
		node.setAttribute ("aria-hidden", "true");
		var text = Browser.document.createTextNode ("BESbswy");
		node.appendChild (text);
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
		Browser.document.body.appendChild (node);
		return node;
		
	}
	#end
	
}

