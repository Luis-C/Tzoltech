import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;

class RingDrawable extends WatchUi.Drawable {
	private var _ringPNG as BitmapResource?;

	public function initialize(params as Dictionary) {
		Drawable.initialize(
			params as
				{
					:height as Double or Float or Long or Number,
					:locX as Double or Float or Long or Number,
					:locY as Double or Float or Long or Number,
					:identifier as Object,
					:width as Double or Float or Long or Number,
					:visible as Boolean,
				}
		);
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

	function getFlowerSVG(value as Number) as BitmapResource {
		// _requiresSpin = true;
		var png = Application.loadResource(Rez.Drawables.OuterRing) as BitmapResource;
		// _currentFlower = "prime";
		return png;
	}

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
		dc.setAntiAlias(true);

		var clockTime = System.getClockTime();
		var angleHours = -clockTime.hour * 15; //
		var angleMinutes = -clockTime.min * 6; // 6 degrees per minute
		var angleSeconds = -clockTime.sec * 6; // 6 degrees per second

		// System.println("Hours: " + clockTime.hour + " Angle: " + angleHours);

		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;

		// dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		// dc.fillCircle(centerX, centerY, 224);

		var firstHue = Utils.extractRGB(Graphics.COLOR_RED);
		var finalHue = Utils.extractRGB(Graphics.COLOR_YELLOW);

		Utils.drawGradientCircle(
			dc,
			centerX,
			160, // start
			224,
			255, //alpha
			firstHue[Utils.CHANNEL_R] as Number,
			finalHue[Utils.CHANNEL_R] as Number,
			firstHue[Utils.CHANNEL_G] as Number,
			finalHue[Utils.CHANNEL_G] as Number,
			firstHue[Utils.CHANNEL_B] as Number,
			finalHue[Utils.CHANNEL_B] as Number
		);

		dc.setPenWidth(25);
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		dc.drawArc(centerX, centerY, 210, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleHours);

		dc.setPenWidth(22);
		dc.drawArc(centerX, centerY, 190, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleMinutes);

		if (System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER) {
			dc.setPenWidth(20);
			dc.drawArc(centerX, centerY, 167, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleSeconds);
		}

		// debug
		// dc.setPenWidth(5);
		// dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		// dc.drawArc(centerX, centerY, 162, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleSeconds);

		// hides extra
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(centerX, centerY, 158);

		var outerRingPNG = getFlowerSVG(0);
		var bitmap = outerRingPNG as BitmapResource;

		var x = 0;
		var y = 0;

		dc.drawBitmap2(x, y, bitmap, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => bitmap.getWidth(),
			:bitmapHeight => bitmap.getHeight(),
			:tintColor => Graphics.COLOR_TRANSPARENT,
		});

		var ring2 = Application.loadResource(Rez.Drawables.MiddleRing) as BitmapResource;

		dc.drawBitmap2(x, y, ring2, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring2.getWidth(),
			:bitmapHeight => ring2.getHeight(),
			:tintColor => Graphics.COLOR_ORANGE,
		});

		var ring3 = Application.loadResource(Rez.Drawables.InnerRing) as BitmapResource;

		dc.drawBitmap2(x, y, ring3, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring3.getWidth(),
			:bitmapHeight => ring3.getHeight(),
			:tintColor => Graphics.COLOR_ORANGE,
		});

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
