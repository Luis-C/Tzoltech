import Toybox.WatchUi;
import Toybox.Lang; // Dictionary
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Application;

class HorizontalTextDrawable extends TextDrawable {
	function initialize(
		options as
			{
				:locX as Number,
				:locY as Number,
			}
	) {
		TextDrawable.initialize(options);
	}

	function _drawText(dc as Dc, options) as Void {
		var screenWidth = dc.getWidth();
		var _CENTER = screenWidth / 2;

		var textColor = _accentColor;
		dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

		if (_vectorFont == null) {
			dc.drawText(_CENTER, _locY, _backupFont, _text, Graphics.TEXT_JUSTIFY_CENTER);
		} else {
			dc.drawText(
				_CENTER,
				_locY,
				_vectorFont as VectorFont,
				_text,
				Graphics.TEXT_JUSTIFY_CENTER
			);
		}
	}
}
