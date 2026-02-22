import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ColorPreview extends WatchUi.Drawable {
	private var _color as ColorType;
	private var _text as String;
	private var _channel as String;
	private var _currColor as ColorType;
	private var _currColorModel as ColorModel;

	//! Constructor
	public function initialize(
		color as ColorType,
		text as String,
		channel as String,
		currColor as ColorModel
	) {
		Drawable.initialize({});
		_color = color;
		_text = text;
		_currColor = currColor.getColor();
		_currColorModel = currColor;
		_channel = channel;
	}

	//! Draw the title with instructions to change the divider type
	//! @param dc Device context
	public function draw(dc as Dc) as Void {
		var dcHeight = dc.getHeight();
		var dcWidth = dc.getWidth();
		var outlineColor = 0x000000;

		dc.setColor(_color, _color);
		dc.fillRoundedRectangle(
			dcWidth / 4,
			dcHeight * 0.5 - (dcHeight * 0.9) / 2,
			dcWidth / 2,
			dcHeight * 0.9,
			25
		);

		switch (_channel.toLower()) {
			case "red":
				_currColor = (_currColor & 0x00ffff) | (_color & 0xff0000);
				outlineColor = 0xff0000;
				break;
			case "green":
				_currColor = (_currColor & 0xff00ff) | (_color & 0x00ff00);
				outlineColor = 0x00ff00;
				break;
			case "blue":
				_currColor = (_currColor & 0xffff00) | (_color & 0x0000ff);
				outlineColor = 0x0000ff;
				break;
		}
		_currColorModel.setColor(_currColor);

		dc.setPenWidth(3);
		dc.setColor(outlineColor, outlineColor);
		dc.drawRoundedRectangle(
			dcWidth / 4,
			dcHeight * 0.5 - (dcHeight * 0.9) / 2,
			dcWidth / 2,
			dcHeight * 0.9,
			25
		);

		// _currColor = (_currColor & 0x00ffff) | (_color & 0xff0000);

		// dc.setColor(_currColor, _currColor);
		// dc.fillRectangle(
		//     dc.getWidth() - dc.getWidth() / 4,
		//     0, //dcHeight - dcHeight / 2,
		//     dc.getWidth() / 4,
		//     dcHeight
		// );

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			dc.getWidth() / 2,
			dc.getHeight() / 2,
			Graphics.FONT_SMALL,
			_text,
			Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
		);

		// This is important so that the picker updates the current color
		WatchUi.requestUpdate();
	}
}

//! Factory that controls which numbers can be picked
class ColorFactory extends WatchUi.PickerFactory {
	private var _start as Number;
	private var _stop as Number;
	private var _increment as Number;
	private var _channel as String;
	private var _currColor as ColorModel;

	private var R_UNIT as Number = 0x55;
	private var G_UNIT as Number = 0x55;
	private var B_UNIT as Number = 0x55;

	private var R_D as Number = 85;
	private var G_D as Number = 85;
	private var B_D as Number = 85;

	// (:regularVersion)
	// private const R_UNIT = 0x8;
	// (:regularVersion)
	// private const G_UNIT = 0x4;
	// (:regularVersion)
	// private const B_UNIT = 0x8;

	// (:regularVersion)
	// private const R_D = 8;
	// (:regularVersion)
	// private const G_D = 4;
	// (:regularVersion)
	// private const B_D = 8;

	// (:mipVersion)
	// private const R_UNIT = 0x55;
	// (:mipVersion)
	// private const G_UNIT = 0x55;
	// (:mipVersion)
	// private const B_UNIT = 0x55;

	// (:mipVersion)
	// private const R_D = 85;
	// (:mipVersion)
	// private const G_D = 85;
	// (:mipVersion)
	// private const B_D = 85;

	//! Constructor
	//! @param start Number to start with
	//! @param stop Number to end with
	//! @param increment How far apart the numbers should be
	//! @param options Dictionary of options
	//! @option options :font The font to use
	//! @option options :format The number format to display
	public function initialize(
		start as Number,
		stop as Number,
		increment as Number,
		channel as String,
		currColor as ColorModel
	) {
		PickerFactory.initialize();

		_start = start;
		_stop = stop;
		_increment = increment;
		_channel = channel;
		_currColor = currColor;

		R_UNIT = 0xff / ((_stop - _start) / _increment);
		G_UNIT = 0xff / ((_stop - _start) / _increment);
		B_UNIT = 0xff / ((_stop - _start) / _increment);

		R_D = R_UNIT;
		G_D = G_UNIT;
		B_D = B_UNIT;
	}

	//! Get the index of a color item
	//! @param value The color to get the index of
	//! @return The index of the number
	public function getIndex(color as ColorType) as Number {
		switch (_channel.toLower()) {
			case "red":
				return ((color >> 16) & 0xff) / R_D;

			case "green":
				return ((color >> 8) & 0xff) / G_D;

			case "blue":
				return (color & 0xff) / B_D;
		}
		return 0;
	}

	//! Generate a Drawable instance for an item
	//! @param index The item index
	//! @param selected true if the current item is selected, false otherwise
	//! @return Drawable for the item
	public function getDrawable(index as Number, selected as Boolean) as Drawable? {
		var value = getValue(index);
		var text = "No item";
		if (value instanceof Number) {
			// text = index.format("%d");
			var hexComponent;

			if (_channel.equals("green")) {
				hexComponent = (G_UNIT * index).format("%02X");
			} else if (_channel.equals("blue")) {
				hexComponent = (B_UNIT * index).format("%02X");
			} else {
				hexComponent = (R_UNIT * index).format("%02X");
			}

			var percentage = ((index * _increment.toFloat()) / (_stop - _start)) * 100.0;

			text = Lang.format("$1$\n$2$%", [hexComponent, percentage.format("%.0f")]);
		}

		return new ColorPreview(value as ColorValue, text, _channel, _currColor);
	}

	//! Get the value of the item at the given index
	//! @param index Index of the item to get the value of
	//! @return Value of the item
	public function getValue(index as Number) as Object? {
		// return _start + index * _increment;
		var color = 0;

		switch (_channel.toLower()) {
			case "red":
				color &= 0x00ffff;
				color |= (R_UNIT * index) << 16;
				break;
			case "green":
				color &= 0xff00ff;
				color |= (G_UNIT * index) << 8;
				break;
			case "blue":
				color &= 0xffff00;
				color |= B_UNIT * index;
				break;
		}

		return color;
	}

	//! Get the number of picker items
	//! @return Number of items
	public function getSize() as Number {
		return (_stop - _start) / _increment + 1;
	}
}
