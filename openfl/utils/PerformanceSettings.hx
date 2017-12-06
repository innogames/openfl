package openfl.utils;

import openfl.filters.BitmapFilter;
import openfl.display.DisplayObject;

@:expose
@:access(openfl.display.DisplayObject)
class PerformanceSettings {
	public static var filtersEnabled(default, null): Bool = true;
	public static var maskingEnabled(default, null): Bool = true;
	
	
	public static function toggleFilters(): String {
		
		filtersEnabled = !filtersEnabled;
		
		__toggleFilters(openfl.Lib.current.stage);
		
		return "Filters " + (filtersEnabled ? "enabled!" : "disabled!");
	}
	
	
	public static function toggleMasking(renderMask: Bool = false): String {
		
		maskingEnabled = !maskingEnabled;
		
		__toggleMasking(openfl.Lib.current.stage, renderMask);
		
		return "Masking " + (maskingEnabled ? "enabled!" : "disabled!");
		
	}
	
	
	private static function __toggleFilters(displayObject: DisplayObject) {
		
		if (filtersEnabled) {
			
			displayObject.filters = displayObject.__cachedFilters;
			
		} else {
			
			var filters: Array<BitmapFilter> = displayObject.filters;
			displayObject.filters = null;
			displayObject.__cachedFilters = filters;
			
		}
		
		var children: Array<DisplayObject> = displayObject.__children;
		if (children != null && children.length > 0) {
			
			for (child in children) {
				
				__toggleFilters(child);
			
			}
			
		}
		
	} 
	
	
	private static function __toggleMasking(displayObject: DisplayObject, renderMask) {
		
		if (maskingEnabled) {
			
			displayObject.mask = displayObject.__cachedMask;
			
		} else {
			
			var mask: DisplayObject = displayObject.mask;
			displayObject.mask = null;
			displayObject.__cachedMask = mask;
			displayObject.__renderMaskWhenDisabled = renderMask;
			
			if (mask != null) {
				
				mask.__isMask = !renderMask;
				
			}
			
		}
		
		var children: Array<DisplayObject> = displayObject.__children;
		if (children != null && children.length > 0) {
			
			for (child in children) {
				
				__toggleMasking(child, renderMask);
				
			}
			
		}
		
	} 
 
}
