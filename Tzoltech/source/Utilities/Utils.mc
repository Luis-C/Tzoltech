import Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Complications;
import Toybox.Time;

module Utils {
	function requiresBurnInProtection() as Boolean {
		var sSettings = System.getDeviceSettings();
		return sSettings.requiresBurnInProtection;
	}

	public enum CHANNEL {
		CHANNEL_R,
		CHANNEL_G,
		CHANNEL_B,
		CHANNEL_A,
	}

	function log(text as String) as Void {
		if (true) {
			var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
			var dateString = Lang.format("$1$:$2$:$3$ $4$ $5$ $6$ $7$ :: ", [
				today.hour,
				today.min,
				today.sec,
				today.day_of_week,
				today.day,
				today.month,
				today.year,
			]);
			System.println(dateString + text);
		}
	}

	function extractRGB(color as Number) as Dictionary<CHANNEL, Number> {
		var blue = color & 0xff; // Extract the lowest 8 bits
		var green = (color >> 8) & 0xff; // Shift right 8 bits, then extract the next 8 bits
		var red = (color >> 16) & 0xff; // Shift right 16 bits, then extract the next 8 bits
		var alpha = (color >> 32) & 0xff;

		return (
			({
				CHANNEL_R => red,
				CHANNEL_G => green,
				CHANNEL_B => blue,
				CHANNEL_A => alpha,
			}) as Dictionary<CHANNEL, Number>
		);
	}

	function mapRange(
		value as Number,
		inputMin as Number,
		inputMax as Number,
		outputMin as Number,
		outputMax as Number
	) as Number {
		return outputMin + ((value - inputMin) * (outputMax - outputMin)) / (inputMax - inputMin);
	}

	function drawGradient(
		dc as Dc,
		x1 as Number,
		y1 as Number,
		w as Number,
		// x2 as Number,
		y2 as Number,
		a as Number,
		r1 as Number,
		r2 as Number,
		g1 as Number,
		g2 as Number,
		b1 as Number,
		b2 as Number
	) as Void {
		var r, g, b;
		for (var i = y1; i < y2; i += 1) {
			r = mapRange(i, y1, y2, r1, r2);
			g = mapRange(i, y1, y2, g1, g2);
			b = mapRange(i, y1, y2, b1, b2);

			dc.setFill(Graphics.createColor(a, r, g, b));
			dc.fillRectangle(x1, i, w, 1);
		}
	}

	function drawGradientCircle(
		dc as Dc,
		// x1 as Number,
		yStart as Number,
		// w as Number,
		// x2 as Number,
		yEnd as Number,
		a as Number,
		r1 as Number,
		r2 as Number,
		g1 as Number,
		g2 as Number,
		b1 as Number,
		b2 as Number
	) as Void {
		var r, g, b;

		// System.println(Lang.format("Drawing circles from: yStart=$1$ yEnd=$2$", [yStart, yEnd]));
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		for (var i = yStart; i < yEnd; i += 1) {
			r = mapRange(i, yStart, yEnd, r1, r2);
			g = mapRange(i, yStart, yEnd, g1, g2);
			b = mapRange(i, yStart, yEnd, b1, b2);

			dc.setFill(Graphics.createColor(a, r, g, b));
			// System.println(
			// 	Lang.format("Drawing circle with color: a=$1$ r=$2$ g=$3$ b=$4$", [a, r, g, b])
			// );
			dc.setColor(Graphics.createColor(a, r, g, b), Graphics.COLOR_TRANSPARENT);

			dc.setPenWidth(1);

			dc.drawCircle(centerX, centerY, i);
		}
	}
}
