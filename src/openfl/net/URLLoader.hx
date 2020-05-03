package openfl.net;

import haxe.io.Bytes;
import lime.net.HTTPRequest;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.HTTPStatusEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLRequestMethod;
import openfl.utils.ByteArray;

class URLLoader extends EventDispatcher {
	public var bytesLoaded:Int;
	public var bytesTotal:Int;
	public var data:Dynamic;
	public var dataFormat:URLLoaderDataFormat;

	private var __httpRequest:HTTPRequest;

	public function new(request:URLRequest = null) {
		super();

		bytesLoaded = 0;
		bytesTotal = 0;
		dataFormat = URLLoaderDataFormat.TEXT;

		if (request != null) {
			load(request);
		}
	}

	public function close():Void {
		if (__httpRequest != null) {
			__httpRequest.cancel();
		}
	}

	public function load(request:URLRequest):Void {
		#if !macro
		var httpRequest = new HTTPRequest();
		__prepareRequest(httpRequest, request);

		if (dataFormat == BINARY) {
			httpRequest.loadBytes()
				.onProgress(httpRequest_onProgress)
				.onError(httpRequest_onError)
				.onComplete(function(bytes) {
					var data = ByteArray.fromBytes(bytes);

					__dispatchStatus();
					this.data = data;

					var event = new Event(Event.COMPLETE);
					dispatchEvent(event);
				});
		} else {
			httpRequest.loadString()
				.onProgress(httpRequest_onProgress)
				.onError(httpRequest_onError)
				.onComplete(function(string) {
					__dispatchStatus();
					this.data = string;

					var event = new Event(Event.COMPLETE);
					dispatchEvent(event);
				});
		}
		#end
	}

	private function __dispatchStatus():Void {
		var event = new HTTPStatusEvent(HTTPStatusEvent.HTTP_STATUS, false, false, __httpRequest.responseStatus);
		event.responseURL = __httpRequest.uri;

		var headers = new Array<URLRequestHeader>();

		#if (!display && !macro)
		if (__httpRequest.enableResponseHeaders && __httpRequest.responseHeaders != null) {
			for (header in __httpRequest.responseHeaders) {
				headers.push(new URLRequestHeader(header.name, header.value));
			}
		}
		#end

		event.responseHeaders = headers;
		dispatchEvent(event);
	}

	private function __prepareRequest(httpRequest:HTTPRequest, request:URLRequest):Void {
		__httpRequest = httpRequest;
		__httpRequest.uri = request.url;
		__httpRequest.method = request.method;

		if (request.data != null) {
			if (Type.typeof(request.data) == TObject) {
				var fields = Reflect.fields(request.data);

				for (field in fields) {
					__httpRequest.formData.set(field, Reflect.field(request.data, field));
				}
			} else if (Std.is(request.data, Bytes)) {
				__httpRequest.data = request.data;
			} else {
				__httpRequest.data = Bytes.ofString(Std.string(request.data));
			}
		}

		__httpRequest.contentType = request.contentType;

		if (request.requestHeaders != null) {
			for (header in request.requestHeaders) {
				__httpRequest.headers.push(new URLRequestHeader(header.name, header.value));
			}
		}

		__httpRequest.followRedirects = request.followRedirects;
		__httpRequest.timeout = Std.int(request.idleTimeout);
		__httpRequest.withCredentials = request.manageCookies;

		// TODO: Better user agent?
		var userAgent = request.userAgent;
		if (userAgent == null)
			userAgent = "Mozilla/5.0 (Windows; U; en) AppleWebKit/420+ (KHTML, like Gecko) OpenFL/1.0";

		__httpRequest.userAgent = request.userAgent;
		__httpRequest.enableResponseHeaders = true;
	}

	// Event Handlers

	private function httpRequest_onError(error:Dynamic):Void {
		__dispatchStatus();

		if (error == 403) {
			var event = new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
			event.text = Std.string(error);
			dispatchEvent(event);
		} else {
			var event = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			event.text = Std.string(error);
			dispatchEvent(event);
		}
	}

	private function httpRequest_onProgress(bytesLoaded:Int, bytesTotal:Int):Void {
		var event = new ProgressEvent(ProgressEvent.PROGRESS);
		event.bytesLoaded = bytesLoaded;
		event.bytesTotal = bytesTotal;
		dispatchEvent(event);
	}
}
