package lime.media;


import lime.media.HTML5AudioContext;
import lime.media.WebAudioContext;


enum AudioContext {
	
	HTML5 (context:HTML5AudioContext);
	WEB (context:WebAudioContext);
	
}