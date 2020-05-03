package openfl._internal.text;

import openfl.geom.Rectangle;
import openfl.text.AntiAliasType;
import openfl.text.Font;
import openfl.text.GridFitType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;
import openfl.text.TextFormat;
import js.html.CanvasRenderingContext2D;
import js.Browser;

@:access(openfl.text.Font)
@:access(openfl.text.TextField)
@:access(openfl.text.TextFormat)
class TextEngine {
	private static inline var GUTTER = 2.0;
	private static inline var UTF8_TAB = 9;
	private static inline var UTF8_ENDLINE = 10;
	private static inline var UTF8_SPACE = 32;
	private static inline var UTF8_HYPHEN = 0x2D;

	private static var __context:CanvasRenderingContext2D;

	public var antiAliasType:AntiAliasType;
	public var autoSize:TextFieldAutoSize;
	public var background:Bool;
	public var backgroundColor:Int;
	public var border:Bool;
	public var borderColor:Int;
	public var bottomScrollV(default, null):Int;
	public var bounds:Rectangle;
	public var caretIndex:Int;
	public var embedFonts:Bool;
	public var gridFitType:GridFitType;
	public var height:Float;
	public var layoutGroups:Array<TextLayoutGroup>;
	public var lineAscents:Array<Float>;
	public var lineBreaks:Array<Int>;
	public var lineDescents:Array<Float>;
	public var lineLeadings:Array<Float>;
	public var lineHeights:Array<Float>;
	public var lineWidths:Array<Float>;
	public var maxChars:Int;
	public var maxScrollH(default, null):Int;
	public var maxScrollV(default, null):Int;
	public var multiline:Bool;
	public var numLines(default, null):Int;
	public var numVisibleLines(default, null):Int;
	public var restrict(default, set):UnicodeString;
	public var scrollH:Int;
	public var scrollV(default, set):Int = 1;
	public var selectable:Bool;
	public var sharpness:Float;
	public var text(default, set):UnicodeString;
	public var textHeight:Float;
	public var textFormatRanges:Array<TextFormatRange>;
	public var textWidth:Float;
	public var type:TextFieldType;
	public var width:Float;
	public var wordWrap:Bool;

	private var textField:TextField;

	private var __hasFocus:Bool;
	private var __restrictRegexp:EReg;
	private var __useIntAdvances:Null<Bool>;

	public function new(textField:TextField) {
		this.textField = textField;

		width = 100;
		height = 100;
		text = "";

		bounds = new Rectangle(0, 0, 0, 0);

		type = TextFieldType.DYNAMIC;
		autoSize = TextFieldAutoSize.NONE;
		embedFonts = false;
		selectable = true;
		borderColor = 0x000000;
		border = false;
		backgroundColor = 0xffffff;
		background = false;
		gridFitType = GridFitType.PIXEL;
		maxChars = 0;
		multiline = false;
		sharpness = 0;
		scrollH = 0;
		wordWrap = false;

		lineAscents = [];
		lineBreaks = [];
		lineDescents = [];
		lineLeadings = [];
		lineHeights = [];
		lineWidths = [];
		layoutGroups = [];
		textFormatRanges = [];

		if (__context == null) {
			#if !nodejs
			__context = Browser.document.createCanvasElement().getContext("2d");
			#end
		}
	}

	private function createRestrictRegexp(restrict:String):EReg {
		var declinedRange = ~/\^(.-.|.)/gu;
		var declined = '';

		var accepted = declinedRange.map(restrict, function(ereg) {
			declined += ereg.matched(1);
			return '';
		});

		var testRegexpParts:Array<String> = [];

		if (accepted.length > 0) {
			testRegexpParts.push('[^$restrict]');
		}

		if (declined.length > 0) {
			testRegexpParts.push('[$declined]');
		}

		return new EReg('(${testRegexpParts.join('|')})', 'g');
	}

	private function getBounds():Void {
		var padding = border ? 1 : 0;

		bounds.width = width + padding;
		bounds.height = height + padding;
	}

	public static function getFormatHeight(format:TextFormat):Float {
		var ascent:Float, descent:Float, leading:Int;

		__context.font = getFont(format);

		if (format.__ascent != null) {
			ascent = format.size * format.__ascent;
			descent = format.size * format.__descent;
		} else {
			ascent = format.size;
			descent = format.size * 0.185;
		}

		leading = format.leading;

		return ascent + descent + leading;
	}

	public static function getFont(format:TextFormat):String {
		var fontName = format.font;
		var bold = format.bold;
		var italic = format.italic;

		if (fontName == null)
			fontName = "_serif";
		var fontNamePrefix = StringTools.replace(StringTools.replace(fontName, " Normal", ""), " Regular", "");

		if (bold && italic && Font.__fontByName.exists(fontNamePrefix + " Bold Italic")) {
			fontName = fontNamePrefix + " Bold Italic";
			bold = false;
			italic = false;
		} else if (bold && Font.__fontByName.exists(fontNamePrefix + " Bold")) {
			fontName = fontNamePrefix + " Bold";
			bold = false;
		} else if (italic && Font.__fontByName.exists(fontNamePrefix + " Italic")) {
			fontName = fontNamePrefix + " Italic";
			italic = false;
		} else {
			// Prevent "extra" bold and italic fonts

			if (bold && (fontName.indexOf(" Bold ") > -1 || StringTools.endsWith(fontName, " Bold"))) {
				bold = false;
			}

			if (italic && (fontName.indexOf(" Italic ") > -1 || StringTools.endsWith(fontName, " Italic"))) {
				italic = false;
			}
		}

		var font = italic ? "italic " : "normal ";
		font += "normal ";
		font += bold ? "bold " : "normal ";
		font += format.size + "px";
		font += "/" + (format.leading + format.size + 3) + "px ";

		font += "" + switch (fontName) {
			case "_sans": "sans-serif";
			case "_serif": "serif";
			case "_typewriter": "monospace";
			default: "'" + ~/^[\s'"]+(.*)[\s'"]+$/.replace(fontName, '$1') + "'";
		}

		return font;
	}

	public function getLine(index:Int):String {
		if (index < 0 || index > lineBreaks.length + 1) {
			return null;
		}

		if (lineBreaks.length == 0) {
			return text;
		} else {
			return text.substring(index > 0 ? lineBreaks[index - 1] : 0, lineBreaks[index]);
		}
	}

	public function getLineBreakIndex(startIndex:Int = 0):Int {
		var cr = text.indexOf("\n", startIndex);
		var lf = text.indexOf("\r", startIndex);

		if (cr == -1)
			return lf;
		if (lf == -1)
			return cr;

		return cr < lf ? cr : lf;
	}

	private function getLineMeasurements():Void {
		lineAscents.resize(0);
		lineDescents.resize(0);
		lineLeadings.resize(0);
		lineHeights.resize(0);
		lineWidths.resize(0);

		var currentLineAscent = 0.0;
		var currentLineDescent = 0.0;
		var currentLineLeading:Null<Int> = null;
		var currentLineHeight = 0.0;
		var currentLineWidth = 0.0;
		var currentTextHeight = 0.0;

		textWidth = 0;
		textHeight = 0;
		numLines = 1;
		numVisibleLines = 0;
		maxScrollH = 0;

		for (group in layoutGroups) {
			while (group.lineIndex > numLines - 1) {
				lineAscents.push(currentLineAscent);
				lineDescents.push(currentLineDescent);
				lineLeadings.push(currentLineLeading != null ? currentLineLeading : 0);
				lineHeights.push(currentLineHeight);
				lineWidths.push(currentLineWidth);

				currentLineAscent = 0;
				currentLineDescent = 0;
				currentLineLeading = null;
				currentLineHeight = 0;
				currentLineWidth = 0;

				numLines++;

				if (textHeight <= height - GUTTER) {
					numVisibleLines++;
				}
			}

			currentLineAscent = Math.max(currentLineAscent, group.ascent);
			currentLineDescent = Math.max(currentLineDescent, group.descent);

			if (currentLineLeading == null) {
				currentLineLeading = group.leading;
			} else {
				currentLineLeading = Std.int(Math.max(currentLineLeading, group.leading));
			}

			currentLineHeight = Math.max(currentLineHeight, group.height);
			currentLineWidth = group.offsetX - GUTTER + group.width;

			if (currentLineWidth > textWidth) {
				textWidth = currentLineWidth;
			}

			currentTextHeight = group.offsetY - GUTTER + group.ascent + group.descent;

			if (currentTextHeight > textHeight) {
				textHeight = currentTextHeight;
			}
		}

		if (textHeight == 0 && textField != null) {
			var currentFormat = textField.__textFormat;
			var ascent, descent, leading, heightValue;

			// __context.font = getFont (currentFormat);

			if (currentFormat.__ascent != null) {
				ascent = currentFormat.size * currentFormat.__ascent;
				descent = currentFormat.size * currentFormat.__descent;
			} else {
				ascent = currentFormat.size;
				descent = currentFormat.size * 0.185;
			}

			leading = currentFormat.leading;

			heightValue = ascent + descent + leading;

			currentLineAscent = ascent;
			currentLineDescent = descent;
			currentLineLeading = leading;

			currentTextHeight = ascent + descent;
			textHeight = currentTextHeight;
		}

		lineAscents.push(currentLineAscent);
		lineDescents.push(currentLineDescent);
		lineLeadings.push(currentLineLeading != null ? currentLineLeading : 0);
		lineHeights.push(currentLineHeight);
		lineWidths.push(currentLineWidth);

		if (numLines == 1) {
			numVisibleLines = 1;

			if (currentLineLeading > 0) {
				textHeight += currentLineLeading;
			}
		} else if (textHeight <= height - GUTTER) {
			numVisibleLines++;
		}

		if (autoSize != NONE) {
			switch (autoSize) {
				case LEFT, RIGHT, CENTER:
					if (!wordWrap /*&& (width < textWidth + 4)*/) {
						width = textWidth + 4;
					}

					height = textHeight + 4;
					numVisibleLines = numLines;

				default:
			}
		}

		updateBottomScrollV();

		if (textWidth > width - 4) {
			maxScrollH = Std.int(textWidth - width + 4);
		} else {
			maxScrollH = 0;
		}

		maxScrollV = numLines - numVisibleLines + 1;
	}

	function updateBottomScrollV() {
		bottomScrollV = numVisibleLines + scrollV - 1;
		if (bottomScrollV < 1)
			bottomScrollV = 1;
		if (bottomScrollV > numLines)
			bottomScrollV = numLines;
	}

	private function getLayoutGroups():Void {
		layoutGroups.resize(0);

		if (text == null || text == "")
			return;

		var rangeIndex = -1;
		var formatRange:TextFormatRange = null;

		var currentFormat = TextField.__defaultTextFormat.clone();

		var leading = 0;
		var ascent = 0.0, maxAscent = 0.0;
		var descent = 0.0;

		var layoutGroup:TextLayoutGroup = null, positions = null;
		var widthValue = 0.0, heightValue = 0.0, maxHeightValue = 0.0;

		var previousSpaceIndex = -2; // -1 equals not found, -2 saves extra comparison in `breakIndex == previousSpaceIndex`
		var spaceIndex = text.indexOf(" ");
		var breakIndex = getLineBreakIndex();

		var offsetX = GUTTER;
		var offsetY = GUTTER;
		var textIndex = 0;
		var lineIndex = 0;
		var lineFormat = null;

		inline function getPositions(text:UnicodeString, startIndex:Int, endIndex:Int) {
			// TODO: optimize

			var positions = [];

			if (__useIntAdvances == null) {
				__useIntAdvances = ~/Trident\/7.0/.match(Browser.navigator.userAgent); // IE
			}

			if (__useIntAdvances) {
				// slower, but more accurate if browser returns Int measurements

				var previousWidth = 0.0;
				var width;

				for (i in startIndex...endIndex) {
					width = measureTextWidth(text.substring(startIndex, i + 1));

					positions.push(width - previousWidth);

					previousWidth = width;
				}
			} else {
				for (i in startIndex...endIndex) {
					var advance;

					if (i < text.length - 1) {
						// Advance can be less for certain letter combinations, e.g. 'Yo' vs. 'Do'
						var nextWidth = measureTextWidth(text.charAt(i + 1));
						var twoWidths = measureTextWidth(text.substr(i, 2));
						advance = twoWidths - nextWidth;
					} else {
						advance = measureTextWidth(text.charAt(i));
					}

					positions.push(advance);
				}
			}

			return positions;
		}

		inline function getPositionsWidth(positions:Array<Float>):Float {
			var width = 0.0;

			for (position in positions) {
				width += position;
			}

			return width;
		}

		inline function getCharIndexAtWidth(positions:Array<Float>, width:Float):Int {
			var charIndex = -1;
			var currentWidth = 0.0;

			for (i in 0...positions.length) {
				currentWidth += positions[i];
				if (currentWidth > width) {
					break;
				} else {
					charIndex = i;
				}
			}

			return charIndex;
		}

		inline function nextLayoutGroup(startIndex, endIndex):Void {
			if (layoutGroup == null || layoutGroup.startIndex != layoutGroup.endIndex) {
				layoutGroup = new TextLayoutGroup(formatRange.format, startIndex, endIndex);
				layoutGroups.push(layoutGroup);
			} else {
				layoutGroup.format = formatRange.format;
				layoutGroup.startIndex = startIndex;
				layoutGroup.endIndex = endIndex;
			}
		}

		inline function nextFormatRange():Void {
			if (rangeIndex < textFormatRanges.length - 1) {
				rangeIndex++;
				formatRange = textFormatRanges[rangeIndex];
				currentFormat.__merge(formatRange.format);

				__context.font = getFont(currentFormat);

				if (currentFormat.__ascent != null) {
					ascent = currentFormat.size * currentFormat.__ascent;
					descent = currentFormat.size * currentFormat.__descent;
				} else {
					ascent = currentFormat.size;
					descent = currentFormat.size * 0.185;
				}

				leading = currentFormat.leading;

				heightValue = ascent + descent + leading;
			}

			if (heightValue > maxHeightValue) {
				maxHeightValue = heightValue;
			}

			if (ascent > maxAscent) {
				maxAscent = ascent;
			}
		}

		inline function alignBaseline():Void {
			// since nextFormatRange may not have been called, have to update these manually
			if (ascent > maxAscent) {
				maxAscent = ascent;
			}

			if (heightValue > maxHeightValue) {
				maxHeightValue = heightValue;
			}

			var i = layoutGroups.length;
			while (--i > -1) {
				var lg = layoutGroups[i];
				if (lg.lineIndex > lineIndex)
					continue;
				if (lg.lineIndex < lineIndex)
					break;

				lg.ascent = maxAscent;
				lg.height = maxHeightValue;
			}

			offsetY += maxHeightValue;

			maxAscent = 0.0;
			maxHeightValue = 0.0;

			++lineIndex;
			offsetX = GUTTER;
		}

		inline function breakLongWords(endIndex:Int):Void {
			var groupEndIndex = endIndex;

			while (offsetX + widthValue > width - GUTTER) {
				var charIndex = getCharIndexAtWidth(positions, width - offsetX - GUTTER);
				// Since the charIndex is zero-based, we add 1 to get the char offset
				var wrapCharOffset = charIndex + 1;
				groupEndIndex = textIndex + wrapCharOffset;

				if (groupEndIndex == textIndex) {
					if (positions.length > 0 && positions[0] > width - 2 * GUTTER) {
						// if the textfield is smaller than a single character and
						groupEndIndex = endIndex + 1;
					} else {
						// if a single character in a new format made the line too long
						offsetX = GUTTER;
						offsetY += layoutGroup.height;
						++lineIndex;
					}

					break;
				} else {
					nextLayoutGroup(textIndex, groupEndIndex);

					layoutGroup.positions = positions.slice(0, wrapCharOffset);
					layoutGroup.offsetX = offsetX;
					layoutGroup.ascent = ascent;
					layoutGroup.descent = descent;
					layoutGroup.leading = leading;
					layoutGroup.lineIndex = lineIndex;
					layoutGroup.offsetY = offsetY;
					layoutGroup.width = getPositionsWidth(layoutGroup.positions);
					layoutGroup.height = heightValue;

					layoutGroup = null;

					alignBaseline();

					positions = positions.slice(wrapCharOffset, endIndex - textIndex);
					widthValue = getPositionsWidth(positions);

					textIndex = groupEndIndex;

					groupEndIndex = endIndex;
				}
			}
		}

		nextFormatRange();

		lineFormat = formatRange.format;
		var wrap;
		var maxLoops = text.length +
			1; // Do an extra iteration to ensure a LayoutGroup is created in case the last line is empty (multiline or trailing line break).

		while (textIndex < maxLoops) {
			if ((breakIndex > -1) && (spaceIndex == -1 || breakIndex < spaceIndex) && (formatRange.end >= breakIndex)) {
				// if a line break is the next thing that needs to be dealt with

				if (textIndex <= breakIndex) {
					positions = getPositions(text, textIndex, breakIndex);
					widthValue = getPositionsWidth(positions);

					if (wordWrap && previousSpaceIndex <= textIndex && width >= 4) {
						breakLongWords(breakIndex);
					}

					nextLayoutGroup(textIndex, breakIndex);

					layoutGroup.positions = positions;
					layoutGroup.offsetX = offsetX;
					layoutGroup.ascent = ascent;
					layoutGroup.descent = descent;
					layoutGroup.leading = leading;
					layoutGroup.lineIndex = lineIndex;
					layoutGroup.offsetY = offsetY;
					layoutGroup.width = widthValue;
					layoutGroup.height = heightValue;

					layoutGroup = null;
				} else if (layoutGroup != null && layoutGroup.startIndex != layoutGroup.endIndex) {
					// Trim the last space from the line width, for correct TextFormatAlign.RIGHT alignment
					if (layoutGroup.endIndex == spaceIndex) {
						layoutGroup.width -= layoutGroup.getAdvance(layoutGroup.positions.length - 1);
					}

					layoutGroup = null;
				}

				if (formatRange.end == breakIndex) {
					nextFormatRange();
					lineFormat = formatRange.format;
				}

				if (breakIndex >= text.length - 1) {
					// Trailing line breaks do not add to textHeight (offsetY), but they do add to numLines (lineIndex)
					offsetY -= maxHeightValue;
				}

				alignBaseline();

				textIndex = breakIndex + 1;
				breakIndex = getLineBreakIndex(textIndex);
			} else if (formatRange.end >= spaceIndex && spaceIndex > -1 && textIndex < formatRange.end) {
				// if a space is the next thing that needs to be dealt with

				if (layoutGroup != null && layoutGroup.startIndex != layoutGroup.endIndex) {
					layoutGroup = null;
				}

				wrap = false;

				while (true) {
					if (textIndex == formatRange.end)
						break;

					var endIndex = -1;

					if (spaceIndex == -1) {
						endIndex = breakIndex;
					} else {
						endIndex = spaceIndex + 1;

						if (breakIndex > -1 && breakIndex < endIndex) {
							endIndex = breakIndex;
						}
					}

					if (endIndex == -1 || endIndex > formatRange.end) {
						endIndex = formatRange.end;
					}

					positions = getPositions(text, textIndex, endIndex);
					widthValue = getPositionsWidth(positions);

					if (lineFormat.align == JUSTIFY) {
						if (positions.length > 0 && textIndex == previousSpaceIndex) {
							// Trim left space of this word
							textIndex++;

							var spaceWidth = positions.shift();
							widthValue -= spaceWidth;
							offsetX += spaceWidth;
						}

						if (positions.length > 0 && endIndex == spaceIndex + 1) {
							// Trim right space of this word
							endIndex--;

							var spaceWidth = positions.pop();
							widthValue -= spaceWidth;
						}
					}

					if (wordWrap) {
						if (offsetX + widthValue > width - GUTTER) {
							wrap = true;

							if (positions.length > 0 && endIndex == spaceIndex + 1) {
								// if last letter is a space, avoid word wrap if possible
								// TODO: Handle multiple spaces

								var lastPosition = positions[positions.length - 1];
								var spaceWidth = lastPosition;

								if (offsetX + widthValue - spaceWidth <= width - 2) {
									wrap = false;
								}
							}
						}
					}

					if (wrap) {
						if (lineFormat.align != JUSTIFY && (layoutGroup != null || layoutGroups.length > 0)) {
							var previous = layoutGroup;
							if (previous == null) {
								previous = layoutGroups[layoutGroups.length - 1];
							}

							// For correct selection rectangles and alignment, trim the trailing space of the previous line:
							previous.width -= previous.getAdvance(previous.positions.length - 1);
							previous.endIndex--;
						}

						var i = layoutGroups.length - 1;
						var offsetCount = 0;

						while (true) {
							layoutGroup = layoutGroups[i];

							if (i > 0 && layoutGroup.startIndex > previousSpaceIndex) {
								offsetCount++;
							} else {
								break;
							}

							i--;
						}

						if (textIndex == previousSpaceIndex + 1) {
							alignBaseline();
						}

						offsetX = GUTTER;

						if (offsetCount > 0) {
							var bumpX = layoutGroups[layoutGroups.length - offsetCount].offsetX;

							for (i in (layoutGroups.length - offsetCount)...layoutGroups.length) {
								layoutGroup = layoutGroups[i];
								layoutGroup.offsetX -= bumpX;
								layoutGroup.offsetY = offsetY;
								layoutGroup.lineIndex = lineIndex;
								offsetX += layoutGroup.width;
							}
						}

						if (width >= 4)
							breakLongWords(endIndex);

						nextLayoutGroup(textIndex, endIndex);

						layoutGroup.positions = positions;
						layoutGroup.offsetX = offsetX;
						layoutGroup.ascent = ascent;
						layoutGroup.descent = descent;
						layoutGroup.leading = leading;
						layoutGroup.lineIndex = lineIndex;
						layoutGroup.offsetY = offsetY;
						layoutGroup.width = widthValue;
						layoutGroup.height = heightValue;

						offsetX += widthValue;

						textIndex = endIndex;

						wrap = false;
					} else {
						if (layoutGroup != null && textIndex == spaceIndex) {
							if (lineFormat.align != JUSTIFY) {
								layoutGroup.endIndex = spaceIndex;
								layoutGroup.positions = layoutGroup.positions.concat(positions);
								layoutGroup.width += widthValue;
							}
						} else if (layoutGroup == null || lineFormat.align == JUSTIFY) {
							nextLayoutGroup(textIndex, endIndex);

							layoutGroup.positions = positions;
							layoutGroup.offsetX = offsetX;
							layoutGroup.ascent = ascent;
							layoutGroup.descent = descent;
							layoutGroup.leading = leading;
							layoutGroup.lineIndex = lineIndex;
							layoutGroup.offsetY = offsetY;
							layoutGroup.width = widthValue;
							layoutGroup.height = heightValue;
						} else {
							layoutGroup.endIndex = endIndex;
							layoutGroup.positions = layoutGroup.positions.concat(positions);
							layoutGroup.width += widthValue;

							// If next char is newline, process it immediately and prevent useless extra layout groups
							if (breakIndex == endIndex)
								endIndex++;
						}

						offsetX += widthValue;

						textIndex = endIndex;
					}

					var nextSpaceIndex = text.indexOf(" ", textIndex);

					if (formatRange.end <= previousSpaceIndex) {
						layoutGroup = null;
						textIndex = formatRange.end;
						nextFormatRange();
					} else {
						// Check if we can continue wrapping this line until the next line-break or end-of-String.
						// When `previousSpaceIndex == breakIndex`, the loop has finished growing layoutGroup.endIndex until the end of this line.

						if (breakIndex == previousSpaceIndex) {
							layoutGroup.endIndex = breakIndex;

							if (breakIndex - layoutGroup.startIndex - layoutGroup.positions.length < 0) {
								// Newline has no size
								layoutGroup.positions.push(0.0);
							}

							textIndex = breakIndex + 1;
						}

						previousSpaceIndex = spaceIndex;
						spaceIndex = nextSpaceIndex;
					}

					if ((breakIndex > -1 && breakIndex <= textIndex && (spaceIndex > breakIndex || spaceIndex == -1))
						|| textIndex > text.length
						|| spaceIndex > formatRange.end) {
						break;
					}
				}
			} else {
				// if there are no line breaks or spaces to deal with next, place remaining text in the format range

				if (textIndex > formatRange.end) {
					break;
				} else if (textIndex < formatRange.end || textIndex == text.length) {
					positions = getPositions(text, textIndex, formatRange.end);
					widthValue = getPositionsWidth(positions);

					if (wordWrap && width >= 4) {
						breakLongWords(formatRange.end);
					}

					nextLayoutGroup(textIndex, formatRange.end);

					layoutGroup.positions = positions;
					layoutGroup.offsetX = offsetX;
					layoutGroup.ascent = ascent;
					layoutGroup.descent = descent;
					layoutGroup.leading = leading;
					layoutGroup.lineIndex = lineIndex;
					layoutGroup.offsetY = offsetY;
					layoutGroup.width = widthValue;
					layoutGroup.height = heightValue;

					offsetX += widthValue;
					textIndex = formatRange.end;
				}

				nextFormatRange();

				if (textIndex == formatRange.end) {
					alignBaseline();

					textIndex++;
					break;
				}
			}
		}
	}

	inline private function measureTextWidth(value:String):Float {
		return __context.measureText(value).width;
	}

	private function setTextAlignment():Void {
		var lineIndex = -1;
		var offsetX = 0.0;
		var totalWidth = this.width - 4;
		var group, lineLength;

		for (i in 0...layoutGroups.length) {
			group = layoutGroups[i];

			if (group.lineIndex != lineIndex) {
				lineIndex = group.lineIndex;

				switch (group.format.align) {
					case CENTER:
						if (lineWidths[lineIndex] < totalWidth) {
							offsetX = Math.round((totalWidth - lineWidths[lineIndex]) / 2);
						} else {
							offsetX = 0;
						}

					case RIGHT:
						if (lineWidths[lineIndex] < totalWidth) {
							offsetX = Math.round(totalWidth - lineWidths[lineIndex]);
						} else {
							offsetX = 0;
						}

					case JUSTIFY:
						if (lineWidths[lineIndex] < totalWidth) {
							lineLength = 1;

							for (j in (i + 1)...layoutGroups.length) {
								if (layoutGroups[j].lineIndex == lineIndex) {
									if (j == 0 || text.charCodeAt(layoutGroups[j].startIndex - 1) == " ".code) {
										lineLength++;
									}
								} else {
									break;
								}
							}

							if (lineLength > 1) {
								group = layoutGroups[i + lineLength - 1];

								var endChar = text.charCodeAt(group.endIndex);
								if (group.endIndex < text.length && endChar != "\n".code && endChar != "\r".code) {
									offsetX = (totalWidth - lineWidths[lineIndex]) / (lineLength - 1);

									var j = 0;
									do {
										if (j > 1 && text.charCodeAt(layoutGroups[j].startIndex - 1) != " ".code) {
											layoutGroups[i + j].offsetX += (offsetX * (j - 1));
											j++;
										}

										layoutGroups[i + j].offsetX += (offsetX * j);
									} while (++j < lineLength);
								}
							}
						}

						offsetX = 0;

					default:
						offsetX = 0;
				}
			}

			if (offsetX > 0) {
				group.offsetX += offsetX;
			}
		}
	}

	private function update():Void {
		if (text == null /*|| text == ""*/ || textFormatRanges.length == 0) {
			lineAscents.resize(0);
			lineBreaks.resize(0);
			lineDescents.resize(0);
			lineLeadings.resize(0);
			lineHeights.resize(0);
			lineWidths.resize(0);
			layoutGroups.resize(0);

			textWidth = 0;
			textHeight = 0;
			numLines = 1;
			maxScrollH = 0;
			maxScrollV = 1;
			bottomScrollV = 1;
		} else {
			getLayoutGroups();
			getLineMeasurements();
			setTextAlignment();
		}

		getBounds();
	}

	// Get & Set Methods

	private function set_restrict(value:String):String {
		if (restrict == value) {
			return restrict;
		}

		restrict = value;

		if (restrict == null || restrict.length == 0) {
			__restrictRegexp = null;
		} else {
			__restrictRegexp = createRestrictRegexp(value);
		}

		return restrict;
	}

	function set_scrollV(value:Int):Int {
		scrollV = value;
		updateBottomScrollV();

		return value;
	}

	private function set_text(value:String):String {
		if (value == null) {
			return text = value;
		}

		if (__restrictRegexp != null) {
			value = __restrictRegexp.split(value).join('');
		}

		if (maxChars > 0 && value.length > maxChars) {
			value = value.substr(0, maxChars);
		}

		text = value;

		return text;
	}
}
