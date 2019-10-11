package lime.utils;


import haxe.io.Path;
import lime.app.Event;
import lime.app.Future;
import lime.app.Promise;
import lime.media.AudioBuffer;
import lime.graphics.Image;
import lime.net.HTTPRequest;
import lime.text.Font;
import lime.utils.AssetType;

#if flash
import flash.display.BitmapData;
import flash.media.Sound;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class AssetLibrary {
	
	
	public var onChange = new Event<Void->Void> ();
	
	private var assetsLoaded:Int;
	private var assetsTotal:Int;
	private var bytesLoaded:Int;
	private var bytesLoadedCache:Map<String, Int>;
	private var bytesTotal:Int;
	private var cachedAudioBuffers = new Map<String, AudioBuffer> ();
	private var cachedBytes = new Map<String, Bytes> ();
	private var cachedFonts = new Map<String, Font> ();
	private var cachedImages = new Map<String, Image> ();
	private var cachedText = new Map<String, String> ();
	private var classTypes = new Map<String, Class<Dynamic>> ();
	private var loaded:Bool;
	private var pathGroups = new Map<String, Array<String>> ();
	private var paths = new Map<String, String> ();
	private var preload = new Map<String, Bool> ();
	private var promise:Promise<AssetLibrary>;
	private var sizes = new Map<String, Int> ();
	private var types = new Map<String, AssetType> ();
	
	
	public function new () {
		
		bytesLoaded = 0;
		bytesTotal = 0;
		
	}
	
	
	public function exists (id:String, type:String):Bool {
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		var assetType = types.get (id);
		
		if (assetType != null) {
			
			if (assetType == requestedType || ((requestedType == SOUND || requestedType == MUSIC) && (assetType == MUSIC || assetType == SOUND))) {
				
				return true;
				
			}
			
			#if flash
			
			if (requestedType == BINARY && (assetType == BINARY || assetType == TEXT || assetType == IMAGE)) {
				
				return true;
				
			} else if (requestedType == TEXT && assetType == BINARY) {
				
				return true;
				
			} else if (requestedType == null || paths.exists (id)) {
				
				return true;
				
			}
			
			#else
			
			if (requestedType == BINARY || requestedType == null || (assetType == BINARY && requestedType == TEXT)) {
				
				return true;
				
			}
			
			#end
			
		}
		
		return false;
		
	}
	
	
	public static function fromBytes (bytes:Bytes, rootPath:String = null):AssetLibrary {
		
		return fromManifest (AssetManifest.fromBytes (bytes, rootPath));
		
	}
	
	
	public static function fromFile (path:String, rootPath:String = null):AssetLibrary {
		
		return fromManifest (AssetManifest.fromFile (path, rootPath));
		
	}
	
	
	public static function fromManifest (manifest:AssetManifest):AssetLibrary {
		
		if (manifest == null) return null;
		
		var library:AssetLibrary = null;
		
		if (manifest.libraryType == null) {
			
			library = new AssetLibrary ();
			
		} else {
			
			var libraryClass = Type.resolveClass (manifest.libraryType);
			
			if (libraryClass != null) {
				
				library = Type.createInstance (libraryClass, manifest.libraryArgs);
				
			} else {
				
				Log.warn ("Could not find library type: " + manifest.libraryType);
				return null;
				
			}
			
		}
		
		library.__fromManifest (manifest);
		
		return library;
		
	}
	
	
	public function getAsset (id:String, type:String):Dynamic {
		
		return switch (type) {
			
			case BINARY: getBytes (id);
			case FONT: getFont (id);
			case IMAGE: getImage (id);
			case MUSIC, SOUND: getAudioBuffer (id);
			case TEXT: getText (id);
			
			case TEMPLATE: throw "Not sure how to get template: " + id;
			default: throw "Unknown asset type: " + type;
			
		}
		
	}
	
	
	public function getAudioBuffer (id:String):AudioBuffer {
		
		if (cachedAudioBuffers.exists (id)) {
			
			return cachedAudioBuffers.get (id);
			
		} else if (classTypes.exists (id)) {
			
			#if flash
			
			var buffer = new AudioBuffer ();
			buffer.src = cast (Type.createInstance (classTypes.get (id), []), Sound);
			return buffer;
			
			#else
			
			return AudioBuffer.fromBytes (cast (Type.createInstance (classTypes.get (id), []), Bytes));
			
			#end
			
		} else {
			
			return AudioBuffer.fromFile (paths.get (id));
			
		}
		
	}
	
	
	public function getBytes (id:String):Bytes {
		
		if (cachedBytes.exists (id)) {
			
			return cachedBytes.get (id);
			
		} else if (cachedText.exists (id)) {
			
			var bytes = Bytes.ofString (cachedText.get (id));
			cachedBytes.set (id, bytes);
			return bytes;
			
		} else if (classTypes.exists (id)) {
			
			#if flash
			
			var data = Type.createInstance (classTypes.get (id), []);
			
			switch (types.get (id)) {
				
				case TEXT, BINARY:
					
					return Bytes.ofData (cast (Type.createInstance (classTypes.get (id), []), flash.utils.ByteArray));
				
				case IMAGE:
					
					var bitmapData = cast (Type.createInstance (classTypes.get (id), []), BitmapData);
					return Bytes.ofData (bitmapData.getPixels (bitmapData.rect));
				
				default:
					
					return null;
				
			}
			
			#else
			
			return cast (Type.createInstance (classTypes.get (id), []), Bytes);
			
			#end
			
		} else {
			
			return Bytes.fromFile (paths.get (id));
			
		}
		
	}
	
	
	public function getFont (id:String):Font {
		
		if (cachedFonts.exists (id)) {
			
			return cachedFonts.get (id);
			
		} else if (classTypes.exists (id)) {
			
			#if flash
			
			var src = Type.createInstance (classTypes.get (id), []);
			
			var font = new Font (src.fontName);
			font.src = src;
			return font;
			
			#else
			
			return cast (Type.createInstance (classTypes.get (id), []), Font);
			
			#end
			
		} else {
			
			return Font.fromFile (paths.get (id));
			
		}
		
	}
	
	
	public function getImage (id:String):Image {
		
		if (cachedImages.exists (id)) {
			
			return cachedImages.get (id);
			
		} else if (classTypes.exists (id)) {
			
			#if flash
			
			return Image.fromBitmapData (cast (Type.createInstance (classTypes.get (id), []), BitmapData));
			
			#else
			
			return cast (Type.createInstance (classTypes.get (id), []), Image);
			
			#end
			
		} else {
			
			return Image.fromFile (paths.get (id));
			
		}
		
	}
	
	
	public function getPath (id:String):String {
		
		return paths.get (id);
		
	}
	
	
	public function getText (id:String):String {
		
		if (cachedText.exists (id)) {
			
			return cachedText.get (id);
			
		} else {
			
			var bytes = getBytes (id);
			
			if (bytes == null) {
				
				return null;
				
			} else {
				
				return bytes.getString (0, bytes.length);
				
			}
			
		}
		
	}
	
	
	public function isLocal (id:String, type:String):Bool {
		
		#if sys
		
		return true;
		
		#else
		
		if (classTypes.exists (id)) {
			
			return true;
			
		}
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		
		return switch (requestedType) {
			
			case IMAGE:
				
				cachedImages.exists (id);
			
			case MUSIC, SOUND:
				
				cachedAudioBuffers.exists (id);
			
			case FONT:
				
				cachedFonts.exists (id);
			
			default:
				
				cachedBytes.exists (id) || cachedText.exists (id);
			
		}
		
		#end
		
	}
	
	
	public function list (type:String):Array<String> {
		
		var requestedType = type != null ? cast (type, AssetType) : null;
		var items = [];
		
		for (id in types.keys ()) {
			
			if (requestedType == null || exists (id, type)) {
				
				items.push (id);
				
			}
			
		}
		
		return items;
		
	}
	
	
	public function loadAsset (id:String, type:String):Future<Dynamic> {
		
		return switch (type) {
			
			case BINARY: loadBytes (id);
			case FONT: loadFont (id);
			case IMAGE: loadImage (id);
			case MUSIC, SOUND: loadAudioBuffer (id);
			case TEXT: loadText (id);
			
			case TEMPLATE: throw "Not sure how to load template: " + id;
			default: throw "Unknown asset type: " + type;
			
		}
		
	}
	
	
	public function load ():Future<AssetLibrary> {
		
		if (loaded) {
			
			return Future.withValue (this);
			
		}
		
		if (promise == null) {
			
			promise = new Promise<AssetLibrary> ();
			bytesLoadedCache = new Map ();
			
			assetsLoaded = 0;
			assetsTotal = 1;
			
			for (id in preload.keys ()) {
				
				if (!preload.get (id)) continue;
				
				Log.verbose ("Preloading asset: " + id + " [" + types.get (id) + "]");
				
				switch (types.get (id)) {
					
					case BINARY:
						
						assetsTotal++;
						
						var future = loadBytes (id);
						future.onProgress (load_onProgress.bind (id));
						future.onError (load_onError.bind (id));
						future.onComplete (loadBytes_onComplete.bind (id));
					
					case FONT:
						
						assetsTotal++;
						
						var future = loadFont (id);
						future.onProgress (load_onProgress.bind (id));
						future.onError (load_onError.bind (id));
						future.onComplete (loadFont_onComplete.bind (id));
					
					case IMAGE:
						
						assetsTotal++;
						
						var future = loadImage (id);
						future.onProgress (load_onProgress.bind (id));
						future.onError (load_onError.bind (id));
						future.onComplete (loadImage_onComplete.bind (id));
					
					case MUSIC, SOUND:
						
						assetsTotal++;
						
						var future = loadAudioBuffer (id);
						future.onProgress (load_onProgress.bind (id));
						future.onError (load_onError.bind (id));
						future.onComplete (loadAudioBuffer_onComplete.bind (id));
					
					case TEXT:
						
						assetsTotal++;
						
						var future = loadText (id);
						future.onProgress (load_onProgress.bind (id));
						future.onError (load_onError.bind (id));
						future.onComplete (loadText_onComplete.bind (id));
					
					default:
					
				}
				
			}
			
			__assetLoaded (null);
			
		}
		
		return promise.future;
		
	}
	
	
	public function loadAudioBuffer (id:String):Future<AudioBuffer> {
		
		if (cachedAudioBuffers.exists (id)) {
			
			return Future.withValue (cachedAudioBuffers.get (id));
			
		} else if (classTypes.exists (id)) {
			
			return Future.withValue (Type.createInstance (classTypes.get (id), []));
			
		} else {
			
			if (pathGroups.exists (id)) {
				
				return AudioBuffer.loadFromFiles (pathGroups.get (id));
				
			} else {
				
				return AudioBuffer.loadFromFile (paths.get (id));
				
			}
			
		}
		
	}
	
	
	public function loadBytes (id:String):Future<Bytes> {
		
		if (cachedBytes.exists (id)) {
			
			return Future.withValue (cachedBytes.get (id));
			
		} else if (classTypes.exists (id)) {
			
			#if flash
			return Future.withValue (Bytes.ofData (Type.createInstance (classTypes.get (id), [])));
			#else
			return Future.withValue (Type.createInstance (classTypes.get (id), []));
			#end
			
		} else {
			
			return Bytes.loadFromFile (paths.get (id));
			
		}
		
	}
	
	
	public function loadFont (id:String):Future<Font> {
		
		if (cachedFonts.exists (id)) {
			
			return Future.withValue (cachedFonts.get (id));
			
		} else if (classTypes.exists (id)) {
			
			var font:Font = Type.createInstance (classTypes.get (id), []);
			
			#if (js && html5)
			return Font.loadFromName (font.name);
			#else
			return Future.withValue (font);
			#end
			
		} else {
			
			#if (js && html5)
			return Font.loadFromName (paths.get (id));
			#else
			return Font.loadFromFile (paths.get (id));
			#end
			
		}
		
	}
	
	
	public static function loadFromBytes (bytes:Bytes, rootPath:String = null):Future<AssetLibrary> {
		
		return AssetManifest.loadFromBytes (bytes, rootPath).then (function (manifest) {
			
			return loadFromManifest (manifest);
			
		});
		
	}
	
	
	public static function loadFromFile (path:String, rootPath:String = null):Future<AssetLibrary> {
		
		return AssetManifest.loadFromFile (path, rootPath).then (function (manifest) {
			
			return loadFromManifest (manifest);
			
		});
		
	}
	
	
	public static function loadFromManifest (manifest:AssetManifest):Future<AssetLibrary> {
		
		var library = fromManifest (manifest);
		
		if (library != null) {
			
			return library.load ();
			
		} else {
			
			return cast Future.withError ("Could not load asset manifest");
			
		}
		
	}
	
	
	public function loadImage (id:String):Future<Image> {
		
		if (cachedImages.exists (id)) {
			
			return Future.withValue (cachedImages.get (id));
			
		} else if (classTypes.exists (id)) {
			
			return Future.withValue (Type.createInstance (classTypes.get (id), []));
			
		} else {
			
			return Image.loadFromFile (paths.get (id));
			
		}
		
	}
	
	
	public function loadText (id:String):Future<String> {
		
		if (cachedText.exists (id)) {
			
			return Future.withValue (cachedText.get (id));
			
		} else if (cachedBytes.exists (id) || classTypes.exists (id)) {
			
			var bytes = getBytes (id);
			
			if (bytes == null) {
				
				return cast Future.withValue (null);
				
			} else {
				
				var text = bytes.getString (0, bytes.length);
				cachedText.set (id, text);
				return Future.withValue (text);
				
			}
			
		} else {
			
			var request = new HTTPRequest<String> ();
			return request.load (paths.get (id));
			
		}
		
	}
	
	
	public function unload ():Void {
		
		
		
	}
	
	
	private function __assetLoaded (id:String):Void {
		
		assetsLoaded++;
		
		if (id != null) {
			
			Log.verbose ("Loaded asset: " + id + " [" + types.get (id) + "] (" + (assetsLoaded - 1) + "/" + (assetsTotal - 1) + ")");
			
		}
		
		if (id != null) {
			
			var size = sizes.get (id);
			
			if (!bytesLoadedCache.exists (id)) {
				
				bytesLoaded += size;
				
			} else {
				
				var cache = bytesLoadedCache.get (id);
				
				if (cache < size) {
					
					bytesLoaded += (size - cache);
					
				}
				
			}
			
			bytesLoadedCache.set (id, size);
			
		}
		
		if (assetsLoaded < assetsTotal) {
			
			promise.progress (bytesLoaded, bytesTotal);
			
		} else {
			
			loaded = true;
			promise.progress (bytesTotal, bytesTotal);
			promise.complete (this);
			
		}
		
	}
	
	
	private function __cacheBreak (path:String):String {
		
		#if web
		if (path.indexOf ("?") > -1) {
			
			path += "&" + Assets.cache.version;
			
		} else {
			
			path += "?" + Assets.cache.version;
			
		}
		#end
		
		return path;
		
	}
	
	
	private function __fromManifest (manifest:AssetManifest):Void {
		
		var hasSize = (manifest.version >= 2);
		var size, id, pathGroup:Array<String>, classRef;
		
		var basePath = manifest.rootPath;
		if (basePath == null) basePath = "";
		if (basePath != "") basePath += "/";
		
		for (asset in manifest.assets) {
			
			size = hasSize ? asset.size : 100;
			id = asset.id;
			
			if (Reflect.hasField (asset, "path")) {
				
				paths.set (id, __cacheBreak (basePath + Reflect.field (asset, "path")));
				
			}
			
			if (Reflect.hasField (asset, "pathGroup")) {
				
				pathGroup = Reflect.field (asset, "pathGroup");
				
				for (i in 0...pathGroup.length) {
					
					pathGroup[i] = __cacheBreak (basePath + pathGroup[i]);
					
				}
				
				pathGroups.set (id, pathGroup);
				
			}
			
			sizes.set (id, size);
			types.set (id, asset.type);
			
			if (Reflect.hasField (asset, "preload")) {
				
				preload.set (id, Reflect.field (asset, "preload"));
				
			}
			
			if (Reflect.hasField (asset, "className")) {
				
				classRef = Type.resolveClass (Reflect.field (asset, "className"));
				
				#if (js && html5 && modular)
				if (classRef == null) {
					
					classRef = untyped $hx_exports[asset.className];
					
				}
				#end
				
				classTypes.set (id, classRef);
				
			}
			
		}
		
		bytesTotal = 0;
		
		for (asset in manifest.assets) {
			
			id = asset.id;
			
			if (preload.exists (id) && preload.get (id)) {
				
				bytesTotal += sizes.get (id);
				
			}
			
		}
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function loadAudioBuffer_onComplete (id:String, audioBuffer:AudioBuffer):Void {
		
		cachedAudioBuffers.set (id, audioBuffer);
		
		if (pathGroups.exists (id)) {
			
			var pathGroup = pathGroups.get (id);
			
			for (otherID in pathGroups.keys ()) {
				
				if (otherID == id) continue;
				
				for (path in pathGroup) {
					
					if (pathGroups.get (otherID).indexOf (path) > -1) {
						
						cachedAudioBuffers.set (otherID, audioBuffer);
						break;
						
					}
					
				}
				
			}
			
		}
		
		__assetLoaded (id);
		
	}
	
	
	private function loadBytes_onComplete (id:String, bytes:Bytes):Void {
		
		cachedBytes.set (id, bytes);
		__assetLoaded (id);
		
	}
	
	
	private function loadFont_onComplete (id:String, font:Font):Void {
		
		cachedFonts.set (id, font);
		__assetLoaded (id);
		
	}
	
	
	private function loadImage_onComplete (id:String, image:Image):Void {
		
		cachedImages.set (id, image);
		__assetLoaded (id);
		
	}
	
	
	private function loadText_onComplete (id:String, text:String):Void {
		
		cachedText.set (id, text);
		__assetLoaded (id);
		
	}
	
	
	private function load_onError (id:String, message:Dynamic):Void {
		
		if (message != null && message != "") {
			
			promise.error ("Error loading asset \"" + id + "\": " + Std.string (message));
			
		} else {
			
			promise.error ("Error loading asset \"" + id + "\"");
			
		}
		
		
	}
	
	
	private function load_onProgress (id:String, bytesLoaded:Int, bytesTotal:Int):Void {
		
		if (bytesLoaded > 0) {
			
			var size = sizes.get (id);
			var percent;
			
			if (bytesTotal > 0) {
				
				// Use a ratio in case the real bytesTotal is different than our precomputed total
				
				percent = (bytesLoaded / bytesTotal);
				if (percent > 1) percent = 1;
				bytesLoaded = Math.floor (percent * size);
				
			} else if (bytesLoaded > size) {
				
				bytesLoaded = size;
				
			}
			
			if (bytesLoadedCache.exists (id)) {
				
				var cache = bytesLoadedCache.get (id);
				
				if (bytesLoaded != cache) {
					
					this.bytesLoaded += (bytesLoaded - cache);
					
				}
				
			} else {
				
				this.bytesLoaded += bytesLoaded;
				
			}
			
			bytesLoadedCache.set (id, bytesLoaded);
			promise.progress (this.bytesLoaded, this.bytesTotal);
			
		}
		
	}
	
	
}