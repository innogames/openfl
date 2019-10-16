package lime.net;

import haxe.io.Bytes;
import lime.app.Future;
import lime._backend.html5.HTML5HTTPRequest as HTTPRequestBackend;
import openfl.net.URLRequestMethod;
import openfl.net.URLRequestHeader;

class HTTPRequest {
	public var contentType:String;
	public var data:Bytes;
	public var enableResponseHeaders:Bool;
	public var followRedirects:Bool;
	public var formData:Map<String, Dynamic>;
	public var headers:Array<URLRequestHeader>;
	public var method:URLRequestMethod;
	public var responseHeaders:Array<URLRequestHeader>;
	public var responseStatus:Int;
	public var timeout:Int;
	public var uri:String;
	public var userAgent:String;
	public var withCredentials:Bool;
	
	private var backend:HTTPRequestBackend;
	
	public function new () {
		
		contentType = "application/x-www-form-urlencoded";
		followRedirects = true;
		enableResponseHeaders = false;
		formData = new Map ();
		headers = [];
		method = GET;
		timeout = #if lime_default_timeout Std.parseInt (haxe.macro.Compiler.getDefine ("lime-default-timeout")) #else 30000 #end;
		withCredentials = false;
		
		backend = new HTTPRequestBackend ();
		backend.init (this);
		
	}
	
	
	public function cancel ():Void {
		
		backend.cancel ();
		
	}

	public function loadBytes ():Future<Bytes> {
		
		return backend.loadData (uri);
		
	}	

	public function loadString ():Future<String> {
		
		return backend.loadText (uri);
		
	}
	
}
