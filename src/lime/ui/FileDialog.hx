package lime.ui;


import haxe.io.Bytes;
import haxe.io.Path;
import lime.app.Event;
import lime.graphics.Image;

import js.html.Blob;

@:access(lime.graphics.Image)
class FileDialog {
	
	
	public var onCancel = new Event<Void->Void> ();
	public var onOpen = new Event<Bytes->Void> ();
	public var onSave = new Event<String->Void> ();
	public var onSelect = new Event<String->Void> ();
	public var onSelectMultiple = new Event<Array<String>->Void> ();
	
	
	public function new () {
		
		
		
	}
	
	
	public function browse (type:FileDialogType = null, filter:String = null, defaultPath:String = null, title:String = null):Bool {
		
		if (type == null) type = FileDialogType.OPEN;
		
		onCancel.dispatch ();
		return false;
		
	}
	
	
	public function open (filter:String = null, defaultPath:String = null, title:String = null):Bool {
		
		onCancel.dispatch ();
		return false;
		
	}
	
	
	public function save (data:Bytes, filter:String = null, defaultPath:String = null, title:String = null):Bool {
		
		if (data == null) {
			
			onCancel.dispatch ();
			return false;
			
		}
		
		// TODO: Cleaner API for mimeType detection
		
		var type = "application/octet-stream";
		var defaultExtension = "";
		
		if (Image.__isPNG (data)) {
			
			type = "image/png";
			defaultExtension = ".png";
			
		} else if (Image.__isJPG (data)) {
			
			type = "image/jpeg";
			defaultExtension = ".jpg";
			
		} else if (Image.__isGIF (data)) {
			
			type = "image/gif";
			defaultExtension = ".gif";
			
		} else if (Image.__isWebP (data)) {
			
			type = "image/webp";
			defaultExtension = ".webp";
			
		}
		
		var path = defaultPath != null ? Path.withoutDirectory (defaultPath) : "download" + defaultExtension;
		var buffer = data.getData ();
		
		untyped window.saveAs (new Blob ([ buffer ], { type: type }), path, true);
		onSave.dispatch (path);
		return true;
		
	}
	
	
}