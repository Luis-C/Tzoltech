import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application.Storage;
import Utils;

class ColorModel extends Object {
	private var _color as ColorType = 0x808080;

	public function initialize() {}

	public function setColor(color as ColorType) as Void {
		_color = color;
	}

	public function getColor() as ColorType {
		return _color;
	}
}

class CustomIcon extends WatchUi.Drawable {
	private var _color as ColorType;

	public function initialize(
		params as
			{
				:color as ColorType,
			}
	) {
		Drawable.initialize({});

		var color = params.get(:color);
		_color = color != null ? color : Graphics.COLOR_LT_GRAY; // fallback
	}

	public function draw(dc as Dc) as Void {
		var xCenter = dc.getWidth() / 2;
		var yCenter = dc.getHeight() / 2;

		dc.setColor(_color, _color);
		dc.fillCircle(xCenter, yCenter, 20);
		// dc.clear();
	}
}

class PickerTitle extends WatchUi.Drawable {
	private var _text as String;
	private var _initialColor as ColorType;
	private var _color as ColorModel;

	//! Constructor
	public function initialize(text as String, initialColor as ColorType, color as ColorModel) {
		Drawable.initialize({});
		_text = text;
		_initialColor = initialColor;
		_color = color;
	}

	//! Draw the title with instructions to change the divider type
	//! @param dc Device context
	public function draw(dc as Dc) as Void {
		var currColor = _color.getColor();
		var dcHeight = dc.getHeight();
		var dcWidth = dc.getWidth();

		dc.setColor(currColor, currColor);
		dc.fillRoundedRectangle(
			dcWidth * 0.5 - (dcWidth * 0.75) / 2, //dcWidth - dcWidth / 4,
			0, //dcHeight - dcHeight / 2,
			dcWidth * 0.75,
			dcHeight,
			15
		);

		dc.setColor(_initialColor, _initialColor);
		dc.fillRoundedRectangle(
			dcWidth * 0.5 - (dcWidth * 0.75) / 2, //dcWidth - dcWidth / 4,
			0, //dcHeight - dcHeight / 2,
			dcWidth * 0.75,
			dcHeight / 2,
			10
		);

		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(
			dcWidth / 2,
			0,
			Graphics.FONT_SYSTEM_SMALL,
			_text,
			Graphics.TEXT_JUSTIFY_CENTER
		);
	}
}

class ColorPicker extends WatchUi.Picker {
	private var _name as String;
	private const N_FACTORIES = 3;

	(:regularVersion)
	private const R_RANGE = 31;
	(:regularVersion)
	private const G_RANGE = 63;
	(:regularVersion)
	private const B_RANGE = 31;

	// (:mipVersion)
	// private const R_RANGE = 3;
	// (:mipVersion)
	// private const G_RANGE = 3;
	// (:mipVersion)
	// private const B_RANGE = 3;

	public function initialize(pickerName as String) {
		_name = pickerName;
		var storedColor = Storage.getValue(_name) as Number?;
		var pickedColor = storedColor != null ? storedColor : Graphics.COLOR_LT_GRAY;
		var previewColor = new $.ColorModel();
		previewColor.setColor(pickedColor);

		var factories = new Array<PickerFactory>[N_FACTORIES];
		factories[0] = new $.ColorFactory(0, R_RANGE, 1, "red", previewColor);
		factories[1] = new $.ColorFactory(0, G_RANGE, 1, "green", previewColor);
		factories[2] = new $.ColorFactory(0, B_RANGE, 1, "blue", previewColor);

		var defaults = new Array<Number>[3];
		defaults[0] = (factories[0] as ColorFactory).getIndex(pickedColor);
		defaults[1] = (factories[1] as ColorFactory).getIndex(pickedColor);
		defaults[2] = (factories[2] as ColorFactory).getIndex(pickedColor);

		Picker.initialize({
			:title => new $.PickerTitle("#RRGGBB", pickedColor, previewColor),
			:pattern => factories,
			:defaults => defaults,
		});
	}
}

class ColorPickerDelegate extends WatchUi.PickerDelegate {
	private var _name as String;
	private var _parentMenuItem as MenuItem; // parent

	//! Constructor
	public function initialize(pickerName as String, parentMenuItem as MenuItem) {
		PickerDelegate.initialize();
		_name = pickerName;
		_parentMenuItem = parentMenuItem;
	}

	//! Handle a cancel event from the picker
	//! @return true if handled, false otherwise
	public function onCancel() as Boolean {
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	public function onAccept(values as Array) {
		values = values;

		var newColor = values[0] | values[1] | values[2];

		var hexString = "#" + (newColor as Number).format("%06X");

		if (_name.equals(StorageKeys.KEY_DATA_COLOR)) {
			Storage.setValue(StorageKeys.KEY_DATA_COLOR, newColor as Number);
			Storage.setValue(StorageKeys.KEY_DATA_COLOR_LABEL, hexString);
		} else if (_name.equals(StorageKeys.KEY_ACCENT_COLOR)) {
			Storage.setValue(StorageKeys.KEY_ACCENT_COLOR, newColor as Number);
			Storage.setValue(StorageKeys.KEY_ACCENT_COLOR_LABEL, hexString);
		}

		// Set Sub Label of parent menu item
		_parentMenuItem.setSubLabel(hexString);
		_parentMenuItem.setIcon(new $.CustomIcon({ :color => newColor as Number }));

		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
