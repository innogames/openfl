package lime.media;


#if (js && html5)
import js.Browser;
#end

#if !lime_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class AudioManager {
	
	
	public static var context:AudioContext;
	
	
	public static function init (context:AudioContext = null) {
		
		if (AudioManager.context == null) {
			
			if (context == null) {
				
				#if (js && html5)
					
					try {
						
						js.Syntax.code ("window.AudioContext = window.AudioContext || window.webkitAudioContext;");
						AudioManager.context = WEB (new js.html.audio.AudioContext ());
						
					} catch (e:Dynamic) {
						
						AudioManager.context = HTML5 (new HTML5AudioContext ());
						
					}
					
				#end
				
			} else {
				
				AudioManager.context = context;
				
			}
			
		}
		
	}
	
	
	public static function resume ():Void {
		
	}
	
	
	public static function shutdown ():Void {
		
		context = null;
		
	}
	
	
	public static function suspend ():Void {
		
	}
	
	
}
