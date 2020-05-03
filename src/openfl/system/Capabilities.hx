package openfl.system;

import haxe.macro.Compiler;
import lime.app.Application;
import lime.system.Locale;
import openfl._internal.Lib;

final class Capabilities {
	public static var avHardwareDisable(default, null) = true;
	public static var cpuArchitecture(get, never):String;
	public static var hasAccessibility(default, null) = false;
	public static var hasAudio(default, null) = true;
	public static var hasAudioEncoder(default, null) = false;
	public static var hasEmbeddedVideo(default, null) = false;
	public static var hasIME(default, null) = false;
	public static var hasMP3(default, null) = false;
	public static var hasPrinting(default, null) = true;
	public static var hasScreenBroadcast(default, null) = false;
	public static var hasScreenPlayback(default, null) = false;
	public static var hasStreamingAudio(default, null) = false;
	public static var hasStreamingVideo(default, null) = false;
	public static var hasTLS(default, null) = true;
	public static var hasVideoEncoder(default, null) = true;
	public static var isDebugger(default, null) = #if debug true #else false #end;
	public static var isEmbeddedInAcrobat(default, null) = false;
	public static var language(get, never):String;
	public static var localFileReadDisable(default, null) = true;
	public static var manufacturer(get, never):String;
	public static var maxLevelIDC(default, null) = 0;
	public static var os(get, never):String;
	public static var pixelAspectRatio(get, never):Float;
	public static var playerType(default, null) = "PlugIn";
	public static var screenColor(default, null) = "color";
	public static var screenDPI(get, never):Float;
	public static var screenResolutionX(get, never):Float;
	public static var screenResolutionY(get, never):Float;
	public static var serverString(default, null) = ""; // TODO
	public static var supports32BitProcesses(default, null) = #if sys true #else false #end;
	public static var supports64BitProcesses(default, null) = #if desktop true #else false #end; // TODO
	public static var touchscreenType(default, null) = TouchscreenType.FINGER; // TODO
	public static var version(get, never):String;

	public static function hasMultiChannelAudio(type:String):Bool {
		return false;
	}

	// Getters & Setters

	private static inline function get_cpuArchitecture():String {
		// TODO: Check architecture
		#if (mobile && !simulator && !emulator)
		return "ARM";
		#else
		return "x86";
		#end
	}

	private static function get_language():String {
		var language = Locale.currentLocale.language;

		if (language != null) {
			language = language.toLowerCase();

			switch (language) {
				case "cs", "da", "nl", "en", "fi", "fr", "de", "hu", "it", "ja", "ko", "nb", "pl", "pt", "ru", "es", "sv", "tr":
					return language;

				case "zh":
					var region = Locale.currentLocale.region;

					if (region != null) {
						switch (region.toUpperCase()) {
							case "TW", "HANT":
								return "zh-TW";

							default:
						}
					}

					return "zh-CN";

				default:
					return "xu";
			}
		}

		return "en";
	}

	private static inline function get_manufacturer():String {
		return "OpenFL";
	}

	private static inline function get_os():String {
		return "HTML5";
	}

	private static function get_pixelAspectRatio():Float {
		return 1;
	}

	private static function get_screenDPI():Float {
		var window = Application.current != null ? Application.current.window : null;
		var screenDPI:Float = 72;

		if (window != null) {
			screenDPI *= window.scale;
		}

		return screenDPI;
	}

	private static function get_screenResolutionX():Float {
		var stage = Lib.current.stage;
		var resolutionX = 0;

		if (stage.window != null) {
			resolutionX = Math.ceil(stage.window.displayWidth * stage.window.scale);
		}

		if (resolutionX > 0) {
			return resolutionX;
		}

		return stage.stageWidth;
	}

	private static function get_screenResolutionY():Float {
		var stage = Lib.current.stage;
		var resolutionY = 0;

		if (stage.window != null) {
			resolutionY = Math.ceil(stage.window.displayHeight * stage.window.scale);
		}

		if (resolutionY > 0) {
			return resolutionY;
		}

		return stage.stageHeight;
	}

	private static function get_version() {
		var value = "WEB";

		if (Compiler.getDefine("openfl") != null) {
			value += " " + StringTools.replace(Compiler.getDefine("openfl"), ".", ",") + ",0";
		}

		return value;
	}
}
