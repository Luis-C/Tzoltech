import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Represents the clock
class TimeDrawable extends WatchUi.Drawable {
	private var _visible as Boolean = true;
	private var _locX as Number = 0;
	private var _locY as Number = 0;
	private var _font as FontType = Graphics.FONT_NUMBER_HOT;
	private var _fontMinutes as FontType = Graphics.FONT_NUMBER_HOT;
	private var _padding as Number = 0;

	function initialize(
		options as
			{
				:locX as Number,
				:locY as Number,
				:visible as Boolean,
			}
	) {
		Drawable.initialize(options);

		if (options.hasKey(:visible)) {
			_visible = options.get(:visible) as Boolean;
		}
		if (options.hasKey(:locX)) {
			_locX = options.get(:locX) as Number;
		}
		if (options.hasKey(:locY)) {
			_locY = options.get(:locY) as Number;
		}
	}

	public function setPadding(padding as Number) as TimeDrawable {
		_padding = padding;
		return self;
	}

	public function setFont(font as FontType) as TimeDrawable {
		_font = font;
		return self;
	}

	public function setFontMinutes(font as FontType) as TimeDrawable {
		_fontMinutes = font;
		return self;
	}

	public function setLoc(x as Number, y as Number) as TimeDrawable {
		_locX = x;
		_locY = y;
		return self;
	}

	private function _getTimeStrings() as [String, String, String] {
		var isHighPowerMode =
			System has :getDisplayMode
				? System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER
				: false;
		var clockTime = System.getClockTime();

		var hours = clockTime.hour;
		if (!System.getDeviceSettings().is24Hour) {
			if (hours > 12) {
				hours = hours - 12;
			}
		}

		var formattedHours = hours.format("%02d");
		var formattedMinutes = clockTime.min.format("%02d");
		var formattedSeconds = isHighPowerMode ? clockTime.sec.format("%02d") : "";
		return [formattedHours, formattedMinutes, formattedSeconds];
	}

	function draw(dc as Dc) as Void {
		if (!_visible) {
			return;
		}

		dc.setAntiAlias(true);

		// Drawing code for the time display goes here
		// Get and show the current time
		var timeStrings = _getTimeStrings();

		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
		// dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK); // debugging

		var textDimensions = dc.getTextDimensions(timeStrings[0], _font);
		var textWidth = textDimensions[0];
		var textHeight = textDimensions[1];

		// _locX,
		// _locY - textHeight - _padding,

		var xFirstNumbers = _locX - textWidth / 2 - _padding / 2;
		var yFirstNumbers = _locY - textHeight / 2;

		dc.drawText(
			xFirstNumbers,
			yFirstNumbers,
			_font,
			timeStrings[0],
			Graphics.TEXT_JUSTIFY_CENTER
		);

		// _locX, _locY
		var xSecondNumbers = _locX + textWidth / 2 + _padding / 2;
		var ySecondNumbers = _locY - textHeight / 2;
		dc.drawText(
			xSecondNumbers,
			ySecondNumbers,
			_fontMinutes,
			timeStrings[1],
			Graphics.TEXT_JUSTIFY_CENTER
		);

		// Utils.log("_locY: " + _locY);
		// Utils.log("textHeight: " + textHeight);
		// Utils.log("_locY - textHeight - _padding: " + (_locY - textHeight - _padding));

		// FOR DEBUGGING
		// dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		// dc.drawCircle(_locX, _locY + _padding, 2);
		// dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		// dc.drawCircle(_locX, _locY - textHeight, 2);

		// dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
		// dc.drawCircle(140, 140, 10);
	}
}
