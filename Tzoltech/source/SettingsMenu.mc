import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;

//! The app settings menu
class SettingsMenu extends WatchUi.Menu2 {
	//! Constructor
	public function initialize() {
		Menu2.initialize({ :title => "Settings" });

		// TOP COLOR
		var currColorHex =
			Storage.getValue(StorageKeys.KEY_ACCENT_COLOR_LABEL) instanceof String
				? Storage.getValue(StorageKeys.KEY_ACCENT_COLOR_LABEL)
				: "";

		var currColorVal =
			Storage.getValue(StorageKeys.KEY_ACCENT_COLOR) instanceof Number
				? Storage.getValue(StorageKeys.KEY_ACCENT_COLOR)
				: Graphics.COLOR_LT_GRAY;

		self.addItem(
			new WatchUi.IconMenuItem(
				$.Rez.Strings.accentColor,
				currColorHex as String,
				StorageKeys.KEY_ACCENT_COLOR,
				new $.CustomIcon({ :color => currColorVal as Number }),
				{
					:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				}
			)
		);

		// BOTTOM COLOR
		currColorHex =
			Storage.getValue(StorageKeys.KEY_DATA_COLOR_LABEL) instanceof String
				? Storage.getValue(StorageKeys.KEY_DATA_COLOR_LABEL)
				: "";

		currColorVal =
			Storage.getValue(StorageKeys.KEY_DATA_COLOR) instanceof Number
				? Storage.getValue(StorageKeys.KEY_DATA_COLOR)
				: Graphics.COLOR_LT_GRAY;
		self.addItem(
			new WatchUi.IconMenuItem(
				$.Rez.Strings.dataColor,
				currColorHex as String,
				StorageKeys.KEY_DATA_COLOR,
				new $.CustomIcon({ :color => currColorVal as Number }),
				{
					:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				}
			)
		);

		self.addItem(new WatchUi.MenuItem($.Rez.Strings.swapColors, null, "SWAP_COLORS", null));

		// if (!Utils.requiresBurnInProtection()) {
		// 	var boolean = Storage.getValue(StorageKeys.KEY_WHITE_BKG) ? true : false;
		// 	self.addItem(
		// 		new WatchUi.ToggleMenuItem(
		// 			$.Rez.Strings.whiteBkg,
		// 			null,
		// 			StorageKeys.KEY_WHITE_BKG,
		// 			boolean,
		// 			null
		// 		)
		// 	);
		// }
		var flags = Storage.getValue(StorageKeys.KEY_VISIBILITY_FLAGS) as Number;

		var boolean = (flags & VisibilityFlags.FLAG_TOP) != 0;
		// Hide toggles
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.topComplication,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_TOP,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem(
				$.Rez.Strings.topComplication,
				null,
				ComplicationLocation.LOC_TOP,
				null
			)
		);

		boolean = (flags & VisibilityFlags.FLAG_CENTER) != 0;
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.centerComplication,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_CENTER,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem(
				$.Rez.Strings.centerComplication,
				null,
				ComplicationLocation.LOC_CENTER,
				null
			)
		);

		boolean = (flags & VisibilityFlags.FLAG_BOTTOM) != 0;
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.bottomComplication,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_BOTTOM,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem(
				$.Rez.Strings.bottomComplication,
				null,
				ComplicationLocation.LOC_BOTTOM,
				null
			)
		);

		boolean = (flags & VisibilityFlags.FLAG_R1) != 0;
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.ringOne,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_R1,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem($.Rez.Strings.ringOne, null, ComplicationLocation.LOC_R1, null)
		);
		boolean = (flags & VisibilityFlags.FLAG_R2) != 0;
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.ringTwo,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_R2,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem($.Rez.Strings.ringTwo, null, ComplicationLocation.LOC_R2, null)
		);

		boolean = (flags & VisibilityFlags.FLAG_R3) != 0;
		self.addItem(
			new WatchUi.ToggleMenuItem(
				$.Rez.Strings.ringThree,
				{
					:enabled => $.Rez.Strings.complicationVisible,
					:disabled => $.Rez.Strings.complicationHidden,
				},
				VisibilityFlags.FLAG_R3,
				boolean,
				null
				// {
				// 	:alignment => MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
				// 	:icon => $.Rez.Drawables.heart,
				// }
			)
		);
		self.addItem(
			new WatchUi.MenuItem($.Rez.Strings.ringThree, null, ComplicationLocation.LOC_R3, null)
		);
		// If radial fonts are supported, show left/right complications
		// if (Toybox.Graphics.Dc has :drawRadialText || Toybox.Graphics.Dc has :drawAngledText) {

		// }
		// }
	}
}
