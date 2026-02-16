import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;
import Utils;

class BackgroundGradient extends WatchUi.Drawable {
	private var _firstHue as Dictionary<CHANNEL, Number>;
	private var _finalHue as Dictionary<CHANNEL, Number>;

	private var CHAR_W as Number = 94; // px
	private var CHAR_H as Number = 142; // px

	private var X_START as Number = 132;
	private var Y_START as Number = 66;

	private var _locY as Number = 0;
	private var _locX as Number = 0;

	// private const X_END = xStart + CHAR_W * 2;
	private var Y_END as Number = Y_START + CHAR_H;
	private var padding as Number = 15;

	public function initialize(
		firstHue as Number,
		finalHue as Number,
		params as
			{
				:visible as Boolean,
			}
	) {
		// You should always call the parent's initializer and
		// in this case you should pass the params along as size
		// and location values may be defined.
		Drawable.initialize(params);

		_firstHue = Utils.extractRGB(firstHue);
		_finalHue = Utils.extractRGB(finalHue);
	}

	function setHues(firstHue as Number?, finalHue as Number?) as BackgroundGradient {
		if (firstHue != null) {
			_firstHue = Utils.extractRGB(firstHue);
		}
		if (finalHue != null) {
			_finalHue = Utils.extractRGB(finalHue);
		}
		return self;
	}

	function setLoc(x as Number, y as Number) as BackgroundGradient {
		_locX = x;
		_locY = y;
		return self;
	}

	function setCharacterDimensions(width as Number, height as Number) as BackgroundGradient {
		CHAR_W = width;
		CHAR_H = height;
		return self;
	}

	function setPadding(padding as Number) as BackgroundGradient {
		self.padding = padding;
		return self;
	}

	function draw(dc as Dc) {
		var clockTime = System.getClockTime();
		var hours = clockTime.hour;
		var minutes = clockTime.min;

		var needsTwoDigits = false;
		var needsTwoDigitsMin = false;

		// Unlcear why this is needed, but it makes the gradient align better with the text.
		var correction = 1;
		Y_START = _locY - CHAR_H - padding + correction;
		X_START = _locX - CHAR_W;
		Y_END = Y_START + CHAR_H;

		if (System.getDeviceSettings().is24Hour) {
			needsTwoDigits = hours > 10 ? true : false;
		} else {
			hours = hours > 12 ? hours - 12 : hours;
			needsTwoDigits = hours > 9 ? true : false;
		}

		var offset = needsTwoDigits ? 0 : CHAR_W;
		var width = needsTwoDigits ? CHAR_W * 2 : CHAR_W;

		// System.println("BackgroundGradient.draw()");
		// var isHighPowerMode = System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER;
		// var textColor = isHighPowerMode ? Graphics.COLOR_DK_GRAY : Graphics.COLOR_DK_GRAY;

		if (!needsTwoDigits) {
			dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(X_START, Y_START, CHAR_W, CHAR_H);
		}

		// First gradient
		Utils.drawGradient(
			dc,
			X_START + offset,
			Y_START,
			width,
			Y_END,
			255, //alpha
			_firstHue[Utils.CHANNEL_R] as Number,
			_finalHue[Utils.CHANNEL_R] as Number,
			_firstHue[Utils.CHANNEL_G] as Number,
			_finalHue[Utils.CHANNEL_G] as Number,
			_firstHue[Utils.CHANNEL_B] as Number,
			_finalHue[Utils.CHANNEL_B] as Number
		);

		if (minutes > 9) {
			needsTwoDigitsMin = true;
		}

		// Second gradient
		var Y_START_2 = Y_END + padding;
		var Y_END_2 = Y_START_2 + CHAR_H;
		Utils.drawGradient(
			dc,
			X_START,
			Y_START_2,
			CHAR_W * 2,
			Y_END_2,
			255, //alpha
			_firstHue[Utils.CHANNEL_R] as Number,
			_finalHue[Utils.CHANNEL_R] as Number,
			_firstHue[Utils.CHANNEL_G] as Number,
			_finalHue[Utils.CHANNEL_G] as Number,
			_firstHue[Utils.CHANNEL_B] as Number,
			_finalHue[Utils.CHANNEL_B] as Number
		);

		if (!needsTwoDigitsMin) {
			dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(X_START, Y_START_2, CHAR_W, CHAR_H);
		}

		// FOR debugging
		// dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		// dc.drawLine(0, Y_START, 280, Y_START);
		// dc.drawLine(0, Y_END, 280, Y_END);

		// dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
		// dc.drawLine(0, Y_START_2, 280, Y_START_2);
		// dc.drawLine(0, Y_END_2, 280, Y_END_2);
	}
}
