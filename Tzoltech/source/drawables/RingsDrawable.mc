import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.SensorHistory;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Utils;

class RingsDrawable extends WatchUi.Drawable {
	private var _firstHue as Dictionary<CHANNEL, Number>;
	private var _finalHue as Dictionary<CHANNEL, Number>;

	private var _percentRing1 as Number or Float = 0;
	private var _percentRing2 as Number or Float = 0;
	private var _percentRing3 as Number or Float = 0;

	private var _iconRing1 as BitmapResource?;
	private var _iconRing2 as BitmapResource?;
	private var _iconRing3 as BitmapResource?;

	private var _bufferedBitmapRef as BufferedBitmapReference;
	private var _bufferedRings as BufferedBitmap;

	public function initialize(
		firstHue as Number,
		finalHue as Number,
		width as Number,
		height as Number,
		params as
			{
				:visible as Boolean,
			}
	) {
		Drawable.initialize(params);

		// The rings are generally static so we load them into a buffered bitmap to improve performance
		// TODO: make buffered bitmap obey size of watchface

		_bufferedBitmapRef = Graphics.createBufferedBitmap({
			:width => width,
			:height => height,
		});

		_bufferedRings =
			Graphics.createBufferedBitmap({
				:width => width,
				:height => height,
			}).get() as BufferedBitmap;

		var ringsDc = _bufferedRings.getDc();

		// DRAW RINGS
		var x = 0;
		var y = 0;
		var outerRingPNG = Application.loadResource(Rez.Drawables.OuterRing) as BitmapResource;
		var ring1 = outerRingPNG as BitmapResource;

		ringsDc.drawBitmap2(x, y, ring1, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring1.getWidth(),
			:bitmapHeight => ring1.getHeight(),
		});

		var ring2 = Application.loadResource(Rez.Drawables.MiddleRing) as BitmapResource;

		ringsDc.drawBitmap2(x, y, ring2, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring2.getWidth(),
			:bitmapHeight => ring2.getHeight(),
		});

		var ring3 = Application.loadResource(Rez.Drawables.InnerRing) as BitmapResource;

		ringsDc.drawBitmap2(x, y, ring3, {
			:bitmapX => 0,
			:bitmapY => 0,
			:bitmapWidth => ring3.getWidth(),
			:bitmapHeight => ring3.getHeight(),
		});

		_firstHue = Utils.extractRGB(firstHue);
		_finalHue = Utils.extractRGB(finalHue);
	}

	function setHues(firstHue as Number?, finalHue as Number?) as RingsDrawable {
		if (firstHue != null) {
			_firstHue = Utils.extractRGB(firstHue);
		}
		if (finalHue != null) {
			_finalHue = Utils.extractRGB(finalHue);
		}
		return self;
	}

	function setPercentage(ring as Number, percentage as Number or Float) as RingsDrawable {
		if (ring == 1) {
			_percentRing1 = percentage;
		} else if (ring == 2) {
			_percentRing2 = percentage;
		} else if (ring == 3) {
			_percentRing3 = percentage;
		}
		return self;
	}

	function setIcon(ring as Number, icon as BitmapResource?) as RingsDrawable {
		if (ring == 1) {
			_iconRing1 = icon;
		} else if (ring == 2) {
			_iconRing2 = icon;
		} else if (ring == 3) {
			_iconRing3 = icon;
		}
		return self;
	}

	function draw(dc) {
		var bufferedBitmap = _bufferedBitmapRef.get();

		if (bufferedBitmap == null || !(bufferedBitmap instanceof BufferedBitmap)) {
			System.println("Error: Buffered bitmap is not available.");
			return;
		}

		var bufferedDc = bufferedBitmap.getDc();

		bufferedDc.clear();

		// bufferedDc.setAntiAlias(false);

		// var clockTime = System.getClockTime();
		// var angleHours = -clockTime.hour * 15; //
		// var angleMinutes = -clockTime.min * 6; // 6 degrees per minute
		// var angleSeconds = -clockTime.sec * 6; // 6 degrees per second

		var angleRing1 = -_percentRing1 * 3.6;
		var angleRing2 = -_percentRing2 * 3.6;
		var angleRing3 = -_percentRing3 * 3.6;

		// System.println("Hours: " + clockTime.hour + " Angle: " + angleHours);

		var centerX = bufferedDc.getWidth() / 2;
		var centerY = bufferedDc.getHeight() / 2;

		// bufferedDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
		// bufferedDc.fillCircle(centerX, centerY, 224);

		// var firstHue = Utils.extractRGB(Graphics.COLOR_RED);
		// var finalHue = Utils.extractRGB(Graphics.COLOR_YELLOW);

		var isHighPowerMode =
			System has :getDisplayMode
				? System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER
				: false;

		var requiresBurnInProtection = System.getDeviceSettings().requiresBurnInProtection;

		var scaleFactor = bufferedDc.getWidth() / 454.0; // Assuming original design is for 454px width

		var hRingWidth = 27 * scaleFactor;
		var mRingWidth = 17 * scaleFactor;
		var sRingWidth = 17 * scaleFactor;

		// where to draw the ring (accounting for the width)
		var hRingR = 215 * scaleFactor;
		var mRingR = 195 * scaleFactor;
		var sRingR = 178 * scaleFactor;

		if (isHighPowerMode || !requiresBurnInProtection) {
			var color = Graphics.createColor(
				255,
				_firstHue[Utils.CHANNEL_R] as Number,
				_firstHue[Utils.CHANNEL_G] as Number,
				_firstHue[Utils.CHANNEL_B] as Number
			);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(hRingWidth);
			bufferedDc.drawCircle(centerX, centerY, hRingR);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(mRingWidth);
			bufferedDc.drawCircle(centerX, centerY, mRingR);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(sRingWidth);
			bufferedDc.drawCircle(centerX, centerY, sRingR);
			// Utils.drawGradientCircle(
			// 	bufferedDc,
			// 	// centerX,
			// 	(173 * scaleFactor).toNumber(), // start
			// 	(227 * scaleFactor).toNumber(),
			// 	255, //alpha
			// 	_firstHue[Utils.CHANNEL_R] as Number,
			// 	_finalHue[Utils.CHANNEL_R] as Number,
			// 	_firstHue[Utils.CHANNEL_G] as Number,
			// 	_finalHue[Utils.CHANNEL_G] as Number,
			// 	_firstHue[Utils.CHANNEL_B] as Number,
			// 	_finalHue[Utils.CHANNEL_B] as Number
			// );
		} else {
			var color = Graphics.createColor(
				255,
				_firstHue[Utils.CHANNEL_R] as Number,
				_firstHue[Utils.CHANNEL_G] as Number,
				_firstHue[Utils.CHANNEL_B] as Number
			);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(hRingWidth);
			bufferedDc.drawCircle(centerX, centerY, hRingR);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(mRingWidth);
			bufferedDc.drawCircle(centerX, centerY, mRingR);
			bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);
			bufferedDc.setPenWidth(sRingWidth);
			bufferedDc.drawCircle(centerX, centerY, sRingR);

			//  many gradients casuing lag

			// Utils.drawGradientCircle(
			// 	dc,
			// 	// centerX,
			// 	(173 * scaleFactor).toNumber(), // start
			// 	(200 * scaleFactor).toNumber(),
			// 	255, //alpha
			// 	_firstHue[Utils.CHANNEL_R] as Number,
			// 	0,
			// 	_firstHue[Utils.CHANNEL_G] as Number,
			// 	0,
			// 	_firstHue[Utils.CHANNEL_B] as Number,
			// 	0
			// );

			// Utils.drawGradientCircle(
			// 	bufferedDc,
			// 	// centerX,
			// 	(200 * scaleFactor).toNumber(), // start
			// 	(227 * scaleFactor).toNumber(),
			// 	255, //alpha
			// 	_firstHue[Utils.CHANNEL_R] as Number,
			// 	0,
			// 	_firstHue[Utils.CHANNEL_G] as Number,
			// 	0,
			// 	_firstHue[Utils.CHANNEL_B] as Number,
			// 	0
			// );
		}

		var color = Graphics.COLOR_DK_GRAY;
		if (!isHighPowerMode && requiresBurnInProtection) {
			color = Graphics.COLOR_LT_GRAY;
		}

		// HOURS
		bufferedDc.setPenWidth(hRingWidth);
		bufferedDc.setColor(color, Graphics.COLOR_TRANSPARENT);

		// System.println(angleRing1);
		// System.println(angleRing2);
		// System.println(angleRing3);

		if (angleRing1 > -359) {
			bufferedDc.drawArc(
				centerX,
				centerY,
				hRingR - 1,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing1 + 90
			);
		}

		// min
		// if (isHighPowerMode) {
		bufferedDc.setPenWidth(mRingWidth);
		if (angleRing2 > -359) {
			bufferedDc.drawArc(
				centerX,
				centerY,
				mRingR - 1,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing2 + 90
			);
		}
		// } else {
		// 	bufferedDc.setPenWidth(sRingWidth);
		// 	bufferedDc.drawArc(centerX, centerY, sRingR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);
		// }

		// seconds
		// if (isHighPowerMode) {
		bufferedDc.setPenWidth(sRingWidth);
		if (angleRing3 > -359) {
			bufferedDc.drawArc(
				centerX,
				centerY,
				sRingR - 1,
				Graphics.ARC_COUNTER_CLOCKWISE,
				90,
				angleRing3 + 90
			);
		}
		// } else {
		// 	bufferedDc.setPenWidth(sRingWidth);
		// 	bufferedDc.drawArc(centerX, centerY, sRingR, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);
		// }

		// debug
		// bufferedDc.setPenWidth(5);
		// bufferedDc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		// bufferedDc.drawArc(centerX, centerY, 162, Graphics.ARC_COUNTER_CLOCKWISE, 0, angleSeconds);

		// hides extra
		// bufferedDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
		// bufferedDc.fillCircle(centerX, centerY, 130);

		// DRAW BUFFERED RINGS:
		bufferedDc.drawBitmap(0, 0, _bufferedRings);

		var iconH, iconW;
		if (_iconRing1 != null) {
			iconH = _iconRing1.getHeight();
			iconW = _iconRing1.getWidth();
		} else {
			iconH = 0;
			iconW = 0;
		}
		// bufferedDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
		// bufferedDc.fillRectangle(227 - iconW / 2, 0, iconW, iconH * 3);

		// bufferedDc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
		// bufferedDc.setPenWidth(1);
		// bufferedDc.drawRectangle(227 - iconW / 2, 0, iconW, iconH * 3);

		if (_iconRing1 != null) {
			// System.println(iconW);
			bufferedDc.drawBitmap2(centerX - iconW * 1.5, iconH * 2, _iconRing1, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing1.getWidth(),
				:bitmapHeight => _iconRing1.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		if (_iconRing2 != null) {
			bufferedDc.drawBitmap2(centerX - iconW / 2, iconH * 2, _iconRing2, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing2.getWidth(),
				:bitmapHeight => _iconRing2.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		if (_iconRing3 != null) {
			bufferedDc.drawBitmap2(centerX + iconW * 0.5, iconH * 2, _iconRing3, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => _iconRing3.getWidth(),
				:bitmapHeight => _iconRing3.getHeight(),
				:tintColor => Graphics.COLOR_LT_GRAY,
			});
		}

		dc.drawBitmap(0, 0, bufferedBitmap);

		if (!isHighPowerMode && requiresBurnInProtection) {
			var overlay = Application.loadResource(Rez.Drawables.RingOverlay) as BitmapResource;
			dc.drawBitmap2(0, 0, overlay, {
				:bitmapX => 0,
				:bitmapY => 0,
				:bitmapWidth => overlay.getWidth(),
				:bitmapHeight => overlay.getHeight(),
			});
		}
	}
}
