import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Application;

class TextDrawable extends WatchUi.Drawable {
	protected var _accentColor as ColorType = Graphics.COLOR_LT_GRAY;
	protected var _backupFont as FontType = Graphics.FONT_XTINY;
	protected var _vectorFont as VectorFont?;

	// protected var _yCoord as Number = 0;
	protected var _locX as Number = 0;
	protected var _locY as Number = 0;
	private var _visible as Boolean = true;

	protected var _text as String = "";

	function initialize(
		options as
			{
				:locX as Number,
				:locY as Number,
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

	public function setColor(color as ColorType) as TextDrawable {
		_accentColor = color;
		return self;
	}

	//! Set visibility of the drawable,
	//! Overrides the Drawable's default setVisible method.
	public function setVisible(isVisible as Boolean) as Void {
		setVisibility(isVisible);
	}

	//! Chainable method to set visibility of the drawable.
	public function setVisibility(isVisible as Boolean) as TextDrawable {
		_visible = isVisible;
		return self;
	}

	public function setFont(vectorFont as VectorFont) as TextDrawable {
		_vectorFont = vectorFont;
		return self;
	}

	public function setLoc(x as Number, y as Number) as TextDrawable {
		_locX = x;
		_locY = y;
		return self;
	}

	public function setText(text as String) as TextDrawable {
		_text = text;
		return self;
	}

	//! Prototype function to be implemented by child classes.
	protected function _drawText(dc as Dc, options as Dictionary) as Void {}

	function draw(dc) as Void {
		if (!_visible) {
			return;
		}

		_drawText(dc, {});
	}
}
