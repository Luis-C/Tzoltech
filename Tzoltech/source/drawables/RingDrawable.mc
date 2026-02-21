import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Utils;

class RingDrawable extends WatchUi.Drawable {
	private var _firstHue as Dictionary<CHANNEL, Number>;
	private var _finalHue as Dictionary<CHANNEL, Number>;

	private var _percentRing1 as Number or Float = 0;
	private var _percentRing2 as Number or Float = 0;
	private var _percentRing3 as Number or Float = 0;

	private var _iconRing1 as BitmapResource?;
	private var _iconRing2 as BitmapResource?;
	private var _iconRing3 as BitmapResource?;

	public function initialize(
		firstHue as Number,
		finalHue as Number,
		params as
			{
				:visible as Boolean,
			}
	) {
		Drawable.initialize(params);

		_firstHue = Utils.extractRGB(firstHue);
		_finalHue = Utils.extractRGB(finalHue);
	}

	function setHues(firstHue as Number?, finalHue as Number?) as RingDrawable {
		if (firstHue != null) {
			_firstHue = Utils.extractRGB(firstHue);
		}
		if (finalHue != null) {
			_finalHue = Utils.extractRGB(finalHue);
		}
		return self;
	}

	function setPercentage(ring as Number, percentage as Number or Float) as RingDrawable {
		if (ring == 1) {
			_percentRing1 = percentage;
		} else if (ring == 2) {
			_percentRing2 = percentage;
		} else if (ring == 3) {
			_percentRing3 = percentage;
		}
		return self;
	}

	function setIcon(ring as Number, icon as BitmapResource?) as RingDrawable {
		if (ring == 1) {
			_iconRing1 = icon;
		} else if (ring == 2) {
			_iconRing2 = icon;
		} else if (ring == 3) {
			_iconRing3 = icon;
		}
		return self;
	}

	// Create a method to get the SensorHistoryIterator object
	// function getIterator() as SensorHistory.SensorHistoryIterator? {
	// 	// // Check device for SensorHistory compatibility
	// 	// if (Toybox has :SensorHistory && Toybox.SensorHistory has :getBodyBatteryHistory) {
	// 	// 	// Set up the method with parameters
	// 	// 	return Toybox.SensorHistory.getBodyBatteryHistory({});
	// 	// }
	// 	// return null;
	// }

	// Potentially change to ENUM
	// function getCurrentFlower(value as Number) as String {
	// 	if (value >= 80) {
	// 		return "prime";
	// 	} else if (value >= 60) {
	// 		return "high";
	// 	} else if (value >= 40) {
	// 		return "moderate";
	// 	} else if (value >= 20) {
	// 		return "low";
	// 	} else {
	// 		return "poor";
	// 	}
	// }

	// function getFlowerSVG(value as Number) as BitmapResource {
	// 	// _requiresSpin = true;
	// 	var png = Application.loadResource(Rez.Drawables.OuterRing) as BitmapResource;
	// 	// _currentFlower = "prime";
	// 	return png;
	// }

	// function getFlowerPNG(value as Number) as BitmapResource {
	// if (value >= 80) {
	// 	var primeFlowerPNG =
	// 		Application.loadResource(Rez.Drawables.PrimeFlowerRaster) as BitmapResource;
	// 	return primeFlowerPNG;
	// } else if (value >= 60) {
	// 	var highFlowerPNG =
	// 		Application.loadResource(Rez.Drawables.HighFlowerRaster) as BitmapResource;
	// 	return highFlowerPNG;
	// } else if (value >= 40) {
	// 	var moderateFlowerPNG =
	// 		Application.loadResource(Rez.Drawables.ModerateFlowerRaster) as BitmapResource;
	// 	return moderateFlowerPNG;
	// } else if (value >= 20) {
	// 	var lowFlowerPNG =
	// 		Application.loadResource(Rez.Drawables.LowFlowerRaster) as BitmapResource;
	// 	return lowFlowerPNG;
	// } else {
	// 	var poorFlowerPNG =
	// 		Application.loadResource(Rez.Drawables.PoorFlowerRaster) as BitmapResource;
	// 	return poorFlowerPNG;
	// }
	// }

	function draw(dc) {
		dc.setAntiAlias(false);

		// var clockTime = System.getClockTime();
		// var angleHours = -clockTime.hour * 15; //
		// var angleMinutes = -clockTime.min * 6; // 6 degrees per minute
		// var angleSeconds = -clockTime.sec * 6; // 6 degrees per second

		var angleRing1 = -_percentRing1 * 3.6;
		var angleRing2 = -_percentRing2 * 3.6;
		var angleRing3 = -_percentRing3 * 3.6;

		// System.println("Hours: " + clockTime.hour + " Angle: " + angleHours);

		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;

		// dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		// dc.fillCircle(centerX, centerY, 224);

		// var firstHue = Utils.extractRGB(Graphics.COLOR_RED);
		// var finalHue = Utils.extractRGB(Graphics.COLOR_YELLOW);

		var isHighPowerMode =
			System has :getDisplayMode
				? System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER
				: false;

		var scaleFactor = dc.getWidth() / 454.0; // Assuming original design is for 454px width

		if (isHighPowerMode) {
			Utils.drawGradientCircle(
				dc,
				// centerX,
				(173 * scaleFactor).toNumber(), // start
				(227 * scaleFactor).toNumber(),
				255, //alpha
				_firstHue[Utils.CHANNEL_R] as Number,
				_finalHue[Utils.CHANNEL_R] as Number,
				_firstHue[Utils.CHANNEL_G] as Number,
				_finalHue[Utils.CHANNEL_G] as Number,
				_firstHue[Utils.CHANNEL_B] as Number,
				_finalHue[Utils.CHANNEL_B] as Number
			);
		} else {
			Utils.drawGradientCircle(
				dc,
				// centerX,
				(173 * scaleFactor).toNumber(), // start
				(200 * scaleFactor).toNumber(),
				255, //alpha
				_firstHue[Utils.CHANNEL_R] as Number,
				0,
				_firstHue[Utils.CHANNEL_G] as Number,
				0,
				_firstHue[Utils.CHANNEL_B] as Number,
				0
			);

			Utils.drawGradientCircle(
				dc,
				// centerX,
				(200 * scaleFactor).toNumber(), // start
				(227 * scaleFactor).toNumber(),
				255, //alpha
				_firstHue[Utils.CHANNEL_R] as Number,
				0,
				_firstHue[Utils.CHANNEL_G] as Number,
				0,
				_firstHue[Utils.CHANNEL_B] as Number,
				0
			);
		}

		var color = Graphics.COLOR_DK_GRAY;
		if (!isHighPowerMode) {
			color = Graphics.COLOR_BLACK;
		}

		var hRingWidth = 23 * scaleFactor;
		var mRingWidth = 17 * scaleFactor;
		var sRingWidth = 14 * scaleFactor;

		// where to draw the ring (accounting for the width)
		var hRingR = 214 * scaleFactor;
		var mRingR = 194 * scaleFactor;
		var sRingR = 178 * scaleFactor;

		// HOURS
		dc.setPenWidth(hRingWidth);
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		// System.println(angleRing1);
		// System.println(angleRing2);
		// System.println(angleRing3);

		if (angleRing1 > -359) {
			dc.drawArc(
				centerX,
				centerY,
				hRingR,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing1 + 90
			);
		}

		// min
		// if (isHighPowerMode) {
		dc.setPenWidth(mRingWidth);
		if (angleRing2 > -359) {
			dc.drawArc(
				centerX,
				centerY,
				mRingR,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing2 + 90
			);
		}
		// } else {
		// 	dc.setPenWidth(sRingWidth);
		// 	dc.drawArc(centerX, centerY, sRingR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);
		// }

		// seconds
		// if (isHighPowerMode) {
		dc.setPenWidth(sRingWidth);
		if (angleRing3 > -359) {
			dc.drawArc(
				centerX,
				centerY,
				sRingR,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing3 + 90
			);
		}
		// } else {
		// 	dc.setPenWidth(sRingWidth);
		// 	dc.drawArc(centerX, centerY, sRingR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);
		// }

		// debug
		// dc.setPenWidth(5);
		// dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		// dc.drawArc(centerX, centerY, 162, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleSeconds);

		// hides extra
		// dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		// dc.fillCircle(centerX, centerY, 130);

		var outerRingPNG = Application.loadResource(Rez.Drawables.OuterRing) as BitmapResource; //getFlowerSVG(0);
		var ring1 = outerRingPNG as BitmapResource;

		var x = 0;
		var y = 0;

		dc.drawBitmap2(x, y, ring1, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring1.getWidth(),
			:bitmapHeight => ring1.getHeight(),
			// :tintColor => Graphics.COLOR_TRANSPARENT,
		});

		var ring2 = Application.loadResource(Rez.Drawables.MiddleRing) as BitmapResource;

		dc.drawBitmap2(x, y, ring2, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring2.getWidth(),
			:bitmapHeight => ring2.getHeight(),
			// :tintColor => Graphics.COLOR_ORANGE,
		});

		var ring3 = Application.loadResource(Rez.Drawables.InnerRing) as BitmapResource;

		dc.drawBitmap2(x, y, ring3, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring3.getWidth(),
			:bitmapHeight => ring3.getHeight(),
			// :tintColor => Graphics.COLOR_ORANGE,
		});

		var iconH, iconW;
		if (_iconRing1 != null) {
			iconH = _iconRing1.getHeight();
			iconW = _iconRing1.getWidth();
		} else {
			iconH = 0;
			iconW = 0;
		}
		// dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		// dc.fillRectangle(227 - iconW / 2, 0, iconW, iconH * 3);

		// dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		// dc.setPenWidth(1);
		// dc.drawRectangle(227 - iconW / 2, 0, iconW, iconH * 3);

		if (_iconRing1 != null) {
			// System.println(iconW);
			dc.drawBitmap2(centerX - iconW * 1.5, iconH * 2, _iconRing1, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing1.getWidth(),
				:bitmapHeight => _iconRing1.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		if (_iconRing2 != null) {
			dc.drawBitmap2(centerX - iconW / 2, iconH * 2, _iconRing2, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing2.getWidth(),
				:bitmapHeight => _iconRing2.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		if (_iconRing3 != null) {
			dc.drawBitmap2(centerX + iconW * 0.5, iconH * 2, _iconRing3, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing3.getWidth(),
				:bitmapHeight => _iconRing3.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		// var color = Utils.getBBColor();
		// var isHighPowerMode = false;
		// if (
		// 	Toybox has :System &&
		// 	Toybox.System has :getDisplayMode &&
		// 	Toybox.System has :DISPLAY_MODE_HIGH_POWER
		// ) {
		// 	isHighPowerMode =
		// 		Toybox.System.getDisplayMode() == Toybox.System.DISPLAY_MODE_HIGH_POWER;
		// }
		// // get the body battery iterator object
		// var bbIterator = getIterator();
		// var sample = bbIterator != null ? bbIterator.next() : null;

		// var value =
		// 	sample != null && (sample.data instanceof Number || sample.data instanceof Float)
		// 		? sample.data as Number
		// 		: 0;

		// var bitmap;

		// TODO: shift to prevent amoled burn-in every couple min.
		// var min = System.getClockTime().min;

		// for debugging:
		// value = min * 2;
		// System.println(value);

		// var currentFlowerName = getCurrentFlower(value);

		// if (currentFlowerName != _currentFlower || _flowerSVG == null) {
		// 	_flowerSVG = getFlowerSVG(value);
		// 	// avoid out of memory on older devices
		// 	_flowerPNG = Graphics has :AffineTransform ? getFlowerPNG(value) : null;
		// }

		// bitmap = isHighPowerMode ? _flowerPNG as BitmapResource : _flowerSVG as BitmapResource;

		// var requiresSpin = _requiresSpin; // Some flowers won't rotate well

		// var screenWidth = dc.getWidth();
		// var screenHeight = dc.getHeight();
		// var bitmapWidth = bitmap.getWidth();
		// var bitmapHeight = bitmap.getHeight();

		// // var SCALE_FACTOR = 0.6 as Float;
		// var SCALE_FACTOR;

		// if (Graphics has :AffineTransform) {
		// 	if (screenHeight > 400) {
		// 		SCALE_FACTOR = 0.6;
		// 	} else {
		// 		SCALE_FACTOR = 0.4;
		// 	}
		// } else {
		// 	SCALE_FACTOR = 1.0;
		// }

		// // Calculate the top-left coordinates to center the bitmap
		// var x = (screenWidth - bitmapWidth * SCALE_FACTOR) / 2;
		// var y = (screenHeight - bitmapHeight * SCALE_FACTOR) / 5;

		// var canBurnIn = false;
		// var settings = System.getDeviceSettings();
		// if (settings has :requiresBurnInProtection) {
		// 	canBurnIn = settings.requiresBurnInProtection;
		// }

		// var requiresShift = canBurnIn; // && min % 5 == 0;
		// var shiftAmount = 5; // pixels to shift

		// if (requiresShift) {
		// 	// Shift in a circular pattern based on the current minute
		// 	var angle = min * (Math.PI / 2); // 0, 90, 180, 270 degrees
		// 	x += Math.round(shiftAmount * Math.cos(angle));
		// 	y += Math.round(shiftAmount * Math.sin(angle));
		// }

		// var transform = null;

		// if (Graphics has :AffineTransform) {
		// 	transform = new Graphics.AffineTransform();
		// 	transform.scale(SCALE_FACTOR, SCALE_FACTOR);

		// 	if (requiresSpin) {
		// 		// rotate in place,
		// 		// rotate 6 degrees every minute
		// 		transform.translate(227 as Float, 227 as Float);
		// 		var radians = min * 6 * (Math.PI / 180.0);
		// 		transform.rotate(radians as Float);
		// 		transform.translate(-227 as Float, -227 as Float);
		// 	}
		// }

		// if (dc has :drawBitmap2) {
		// 	// Ensure we provide a non-null AffineTransform when Graphics supports it
		// 	if (Graphics has :AffineTransform && transform == null) {
		// 		transform = new Graphics.AffineTransform();
		// 	}

		// 	dc.drawBitmap2(x, y, bitmap, {
		// 		:bitmapX => 0,
		// 		:bitmapY => 0,
		// 		:bitmapWidth => bitmap.getWidth(),
		// 		:bitmapHeight => bitmap.getHeight(),
		// 		:tintColor => (isHighPowerMode ? Graphics.COLOR_TRANSPARENT : color) as
		// 		Graphics.ColorType,
		// 		:transform => transform as Graphics.AffineTransform,
		// 	});
		// } else {
		// 	// Legacy method for older devices
		// 	dc.drawBitmap(x, y, bitmap);
		// }
	}
}
