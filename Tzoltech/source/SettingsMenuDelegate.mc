import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Complications;

//! Input handler for the app settings menu
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
	//! Constructor
	public function initialize() {
		Menu2InputDelegate.initialize();
	}

	//! Handle a menu item being selected
	//! @param menuItem The menu item selected
	public function onSelect(menuItem as MenuItem) as Void {
		var menuId = menuItem.getId();
		var title = Rez.Strings.accentColor; //new $.DividerTitle();

		if (menuItem instanceof ToggleMenuItem) {
			var flags = Storage.getValue(StorageKeys.KEY_VISIBILITY_FLAGS) as Number;
			var flag = menuId as VisibilityFlags.Value;
			var newFlags = menuItem.isEnabled() ? flags | flag : flags & ~flag;
			Storage.setValue(StorageKeys.KEY_VISIBILITY_FLAGS, newFlags);

			// NOTE: attempted dynamic menu item addition, however
			// you can not select where to add a menu Item so they're added at
			// the bottom. Which is not ideal.
		} else if (menuId != null && menuId.equals(StorageKeys.KEY_ACCENT_COLOR)) {
			WatchUi.pushView(
				new $.ColorPicker(StorageKeys.KEY_ACCENT_COLOR),
				new $.ColorPickerDelegate(StorageKeys.KEY_ACCENT_COLOR, menuItem),
				WatchUi.SLIDE_IMMEDIATE
			);
		} else if (menuId != null && menuId.equals(StorageKeys.KEY_DATA_COLOR)) {
			WatchUi.pushView(
				new $.ColorPicker(StorageKeys.KEY_DATA_COLOR),
				new $.ColorPickerDelegate(StorageKeys.KEY_DATA_COLOR, menuItem),
				WatchUi.SLIDE_IMMEDIATE
			);
		} else if (
			menuId != null &&
			(menuId.equals(ComplicationLocation.LOC_TOP) ||
				menuId.equals(ComplicationLocation.LOC_CENTER) ||
				menuId.equals(ComplicationLocation.LOC_BOTTOM))
		) {
			title = Rez.Strings.complications;
			var compMenu = new WatchUi.Menu2({ :title => title });
			var compIterator = Complications.getComplications();
			var currComp = compIterator.next();
			while (currComp != null) {
				// The assumption is that if it is a Garmin complication we will have label and type
				if (currComp.complicationId == null) {
					currComp = compIterator.next();
					continue;
				}

				var compType = (currComp.complicationId as Complications.Id).getType();
				compMenu.addItem(new MenuItem(currComp.longLabel as String, null, compType, null));
				currComp = compIterator.next();
			}

			WatchUi.pushView(compMenu, new $.Menu2SampleSubMenuDelegate(menuId), WatchUi.SLIDE_UP);
		} else if (
			menuId != null &&
			(menuId.equals(ComplicationLocation.LOC_R1) ||
				menuId.equals(ComplicationLocation.LOC_R2) ||
				menuId.equals(ComplicationLocation.LOC_R3))
		) {
			title = Rez.Strings.complications;
			var compMenu = new WatchUi.Menu2({ :title => title });
			var compIterator = Complications.getComplications();
			var currComp = compIterator.next();

			var allowedRingComplications = [
				// Complications.Type.STEP_COUNT, // NOTE: consider goals
				// Complications.COMPLICATION_TYPE_HEART_RATE, // TODO:
				Complications.COMPLICATION_TYPE_FLOORS_CLIMBED,
				Complications.COMPLICATION_TYPE_STEPS,
				Complications.COMPLICATION_TYPE_INTENSITY_MINUTES,
				Complications.COMPLICATION_TYPE_RECOVERY_TIME,
				Complications.COMPLICATION_TYPE_BATTERY,
				Complications.COMPLICATION_TYPE_BODY_BATTERY,
				Complications.COMPLICATION_TYPE_PULSE_OX,
				Complications.COMPLICATION_TYPE_STRESS,
				Complications.COMPLICATION_TYPE_SOLAR_INPUT,
			];

			while (currComp != null) {
				// The assumption is that if it is a Garmin complication we will have label and type
				if (currComp.complicationId == null) {
					currComp = compIterator.next();
					continue;
				}

				var compType = (currComp.complicationId as Complications.Id).getType();

				if (allowedRingComplications.indexOf(compType) < 0) {
					currComp = compIterator.next();
					continue;
				}
				compMenu.addItem(new MenuItem(currComp.longLabel as String, null, compType, null));

				currComp = compIterator.next();
			}

			WatchUi.pushView(compMenu, new $.Menu2SampleSubMenuDelegate(menuId), WatchUi.SLIDE_UP);
		} else if (menuId != null && menuId.equals("SWAP_COLORS")) {
			var accentColor = Storage.getValue(StorageKeys.KEY_ACCENT_COLOR) as Number?;
			var dataColor = Storage.getValue(StorageKeys.KEY_DATA_COLOR) as Number?;

			if (accentColor != null && dataColor != null) {
				Storage.setValue(StorageKeys.KEY_ACCENT_COLOR, dataColor);
				Storage.setValue(StorageKeys.KEY_DATA_COLOR, accentColor);

				var accentColorLabel =
					Storage.getValue(StorageKeys.KEY_ACCENT_COLOR_LABEL) as String?;
				var dataColorLabel = Storage.getValue(StorageKeys.KEY_DATA_COLOR_LABEL) as String?;

				if (accentColorLabel != null && dataColorLabel != null) {
					Storage.setValue(StorageKeys.KEY_ACCENT_COLOR_LABEL, dataColorLabel);
					Storage.setValue(StorageKeys.KEY_DATA_COLOR_LABEL, accentColorLabel);
				}
			}
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		} else {
			Utils.log("Selected item with id: " + menuItem.getId());
		}
	}
}

//! This is the menu input delegate shared by all the basic sub-menus in the application
class Menu2SampleSubMenuDelegate extends WatchUi.Menu2InputDelegate {
	private var _menuId as Object;

	//! Constructor
	//! @param menu The menu to be used
	public function initialize(
		// menu as WatchUi.Menu2,
		menuId as Object
	) {
		// menuItem as MenuItem
		// _menu = menu;
		_menuId = menuId;
		// _parentMenuItem = menuItem;
		Menu2InputDelegate.initialize();
	}

	//! Handle an item being selected
	//! @param item The selected menu item
	public function onSelect(item as MenuItem) as Void {
		var itemId = item.getId();

		if (item instanceof WatchUi.IconMenuItem) {
		} else if (item instanceof CheckboxMenuItem) {
			if (itemId instanceof String) {
				Storage.setValue(itemId, item.isChecked());
			}
		} else if (item instanceof MenuItem) {
			if (_menuId instanceof String && itemId instanceof Number) {
				Storage.setValue(_menuId, itemId);
			}

			WatchUi.popView(WatchUi.SLIDE_DOWN);
		}

		$.getApp().notifyComplicationChanged();

		WatchUi.requestUpdate();
	}

	//! Handle the done item being selected
	// This method is only triggered by a CheckboxMenu
	public function onDone() as Void {
		WatchUi.popView(WatchUi.SLIDE_DOWN);
	}
}
