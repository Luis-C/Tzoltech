import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Complications;
import Toybox.Application;

class TzoltechView extends WatchUi.WatchFace {
	private var _settingsChanged as Boolean = false;

	private var _timeDrawable as TimeDrawable = new TimeDrawable({});
	private var _complicationCenter as HorizontalTextDrawable = new HorizontalTextDrawable({});
	private var _complicationTop as HorizontalTextDrawable = new HorizontalTextDrawable({});
	private var _complicationBottom as HorizontalTextDrawable = new HorizontalTextDrawable({});
	private var _bgGradient as BackgroundGradient = new BackgroundGradient(
		Graphics.COLOR_RED,
		Graphics.COLOR_YELLOW,
		{}
	);
	private var _ringsDrawable as RingDrawable = new RingDrawable(
		Graphics.COLOR_RED,
		Graphics.COLOR_YELLOW,
		{}
	);

	// LAYOUT
	private var _padding as Number = 14;
	private var _vectorFontSize as Number = 34;

	private const _DEFAULT_TOP_COMPLICATION = Complications.COMPLICATION_TYPE_DATE;
	private const _DEFAULT_CENTER_COMPLICATION = Complications.COMPLICATION_TYPE_TRAINING_STATUS;
	private const _DEFAULT_BOTTOM_COMPLICATION = Complications.COMPLICATION_TYPE_ALTITUDE;
	private const _DEFAULT_RING_3 = Complications.COMPLICATION_TYPE_BATTERY;
	private const _DEFAULT_RING_2 = Complications.COMPLICATION_TYPE_BODY_BATTERY;
	private const _DEFAULT_RING_1 = Complications.COMPLICATION_TYPE_STRESS;
	private var _complicationAssignments as Dictionary<String, Complications.Id> = {
		ComplicationLocation.LOC_TOP => new Complications.Id(_DEFAULT_TOP_COMPLICATION),
		ComplicationLocation.LOC_CENTER => new Complications.Id(_DEFAULT_CENTER_COMPLICATION),
		ComplicationLocation.LOC_BOTTOM => new Complications.Id(_DEFAULT_BOTTOM_COMPLICATION),
		ComplicationLocation.LOC_R3 => new Complications.Id(_DEFAULT_RING_3),
		ComplicationLocation.LOC_R2 => new Complications.Id(_DEFAULT_RING_2),
		ComplicationLocation.LOC_R1 => new Complications.Id(_DEFAULT_RING_1),
	};

	function initialize() {
		WatchFace.initialize();

		_initializeStorage();
		Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));

		// Initial load of complications
		_loadComplications();
	}

	function onComplicationChanged(complicationId as Id) as Void {
		// search dict for complicationId
		var slotLocations = _complicationAssignments.keys(); // i.e top, center, bottom

		for (var i = 0; i < slotLocations.size(); i++) {
			var slotLocation = slotLocations[i] as ComplicationLocation.Value;
			var compId = _complicationAssignments.get(slotLocation);
			if (compId != null && compId.equals(complicationId)) {
				var formatted = ComplicationUtils.getFormattedCompStr(complicationId, slotLocation);
				_updateComplicationText(formatted, slotLocation);

				// Special cases:
				if (slotLocation.equals(ComplicationLocation.LOC_R1)) {
					var value = ComplicationUtils.getComplicationValue(complicationId);
					// var label = ComplicationUtils.getComplicationLabel(complicationId);
					var icon = ComplicationUtils.getComplicationIcon(complicationId.getType());

					if (icon != null) {
						_ringsDrawable.setIcon(1, icon);
					}

					_ringsDrawable.setPercentage(1, value);
				} else if (slotLocation.equals(ComplicationLocation.LOC_R2)) {
					var value = ComplicationUtils.getComplicationValue(complicationId);
					// var label = ComplicationUtils.getComplicationLabel(complicationId);
					var icon = ComplicationUtils.getComplicationIcon(complicationId.getType());

					if (icon != null) {
						_ringsDrawable.setIcon(2, icon);
					}
					_ringsDrawable.setPercentage(2, value);
				} else if (slotLocation.equals(ComplicationLocation.LOC_R3)) {
					var value = ComplicationUtils.getComplicationValue(complicationId);
					// var label = ComplicationUtils.getComplicationLabel(complicationId);
					var icon = ComplicationUtils.getComplicationIcon(complicationId.getType());

					if (icon != null) {
						_ringsDrawable.setIcon(3, icon);
					}
					_ringsDrawable.setPercentage(3, value);
				}
			}
		}

		// Helps prevent delay when changing complication
		// WatchUi.requestUpdate();
	}

	private function _updateComplicationText(
		text as String,
		location as ComplicationLocation.Value
	) as Void {
		switch (location) {
			case ComplicationLocation.LOC_TOP:
				_complicationTop.setText(text);
				break;
			case ComplicationLocation.LOC_CENTER:
				_complicationCenter.setText(text);
				break;
			case ComplicationLocation.LOC_BOTTOM:
				_complicationBottom.setText(text);
				break;
		}
		WatchUi.requestUpdate();
	}

	private function _loadComplications() as Void {
		var complicationLocations = _complicationAssignments.keys();

		for (var i = 0; i < complicationLocations.size(); i++) {
			var location = complicationLocations[i];
			var storedComplicationType = Storage.getValue(location as ComplicationLocation.Value);

			if (storedComplicationType instanceof Number) {
				_complicationAssignments[location] = new Complications.Id(
					storedComplicationType as Complications.Type
				);
			}
		}

		_subscribeToComplications();
	}

	private function _subscribeToComplications() as Void {
		var complicationLocations = _complicationAssignments.keys();
		for (var i = 0; i < complicationLocations.size(); i++) {
			var location = complicationLocations[i];
			ComplicationUtils.safeSubscribeToUpdates(_complicationAssignments[location]);
		}
		WatchUi.requestUpdate();
	}

	private function _getVectorFont(textSize as Number) as VectorFont? {
		var vectorFont = Graphics.getVectorFont({
			:face => [
				"ExoSemiBold",
				"BionicBold",
				"BionicSemiBold",
				"Yantramanav",
				"YantramanavRegular",
				"RobotoCondensedBold",
				"RobotoCondensedRegular",
				"KosugiRegular",
				"NanumGothicBold", // (jpn)
				"NotoSansSCMedium", // Chinese (zhs)
			],
			:size => textSize,
		});
		return vectorFont;
	}

	// Load your resources here
	function onLayout(dc as Dc) as Void {
		dc.setAntiAlias(true);
		setLayout([
			_ringsDrawable,
			_bgGradient,
			_timeDrawable,
			_complicationTop,
			_complicationCenter,
			_complicationBottom,
		]);
		var fontRegular = WatchUi.loadResource($.Rez.Fonts.tzoltechLarge) as FontResource;

		var dcHeight = dc.getHeight();
		var dcWidth = dc.getWidth();
		var centerX = dcWidth / 2;
		var centerY = dcHeight / 2;

		_timeDrawable
			.setFont(fontRegular)
			.setFontMinutes(fontRegular)
			.setLoc(centerX, centerY)
			.setPadding(_padding);

		var clockTextDimensions = dc.getTextDimensions("1", fontRegular);

		_bgGradient
			.setCharacterDimensions(clockTextDimensions[0], clockTextDimensions[1])
			.setLoc(centerX, centerY)
			.setPadding(_padding);

		var compString = "--";
		var vectorFont = _getVectorFont(_vectorFontSize);
		var textDimensions = dc.getTextDimensions(compString, Graphics.FONT_XTINY);
		var fontDescent = Graphics.getFontDescent(Graphics.FONT_XTINY);

		if (vectorFont != null) {
			_complicationTop.setFont(vectorFont);
			_complicationCenter.setFont(vectorFont);
			_complicationBottom.setFont(vectorFont);

			// _indicatorLeft.setFont(vectorFont);
			// _indicatorRight.setFont(vectorFont);

			textDimensions = dc.getTextDimensions(compString, vectorFont);
			fontDescent = Graphics.getFontDescent(vectorFont);
		}

		var compTextHeight = textDimensions[1];
		// _complicationCenter.setLoc(centerX, centerY - compTextHeight + fontDescent);
		// _complicationTop.setLoc(
		// 	centerX,
		// 	centerY - (clockTextDimensions[1] + _padding + compTextHeight)
		// );
		// _complicationBottom.setLoc(centerX, centerY + clockTextDimensions[1]);
		_complicationCenter.setLoc(centerX, centerY + clockTextDimensions[1] / 2);
		_complicationTop.setLoc(centerX, centerY - (clockTextDimensions[1] / 2 + compTextHeight));
		_complicationBottom.setLoc(centerX, centerY + clockTextDimensions[1] / 2 + compTextHeight);
	}

	private function _initializeStorage() as Void {
		// 0b111111 means all complications visible
		if (Storage.getValue(StorageKeys.KEY_VISIBILITY_FLAGS) == null) {
			Storage.setValue(StorageKeys.KEY_VISIBILITY_FLAGS, 63);
		}
	}

	private function _setComplicationVisibility() as Void {
		var flags = Storage.getValue(StorageKeys.KEY_VISIBILITY_FLAGS) as Number;

		// _indicatorLeft.setVisible((flags & VisibilityFlags.FLAG_LEFT) != 0);
		// _indicatorRight.setVisible((flags & VisibilityFlags.FLAG_RIGHT) != 0);
		_complicationTop.setVisible((flags & VisibilityFlags.FLAG_TOP) != 0);
		_complicationCenter.setVisible((flags & VisibilityFlags.FLAG_CENTER) != 0);
		_complicationBottom.setVisible((flags & VisibilityFlags.FLAG_BOTTOM) != 0);
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() as Void {
		_setComplicationVisibility();

		if (_settingsChanged) {
			_loadComplications();
			// Update text manually, this one might not be necessary
			var slotLocations = _complicationAssignments.keys();
			for (var i = 0; i < slotLocations.size(); i++) {
				var slotLocation = slotLocations[i] as ComplicationLocation.Value;
				var complicationId = _complicationAssignments.get(slotLocation) as Complications.Id;
				var formatted = ComplicationUtils.getFormattedCompStr(complicationId, slotLocation);
				_updateComplicationText(formatted, slotLocation);
			}
			_settingsChanged = false;
		} else {
			_subscribeToComplications();
		}

		var storedAccentColor = Storage.getValue(StorageKeys.KEY_ACCENT_COLOR);
		var storedDataColor = Storage.getValue(StorageKeys.KEY_DATA_COLOR);

		var accentColorToUse, dataColorToUse;

		if (storedDataColor instanceof Number) {
			dataColorToUse = storedDataColor;
			// _indicatorRight.setHues(null, dataColorToUse);
			// _indicatorLeft.setHues(null, dataColorToUse);
			_ringsDrawable.setHues(null, dataColorToUse);
			_bgGradient.setHues(null, dataColorToUse);
		}

		if (storedAccentColor instanceof Number) {
			accentColorToUse = storedAccentColor;
			// _indicatorRight.setHues(accentColorToUse, null);
			// _indicatorLeft.setHues(accentColorToUse, null);
			_ringsDrawable.setHues(accentColorToUse, null);
			_bgGradient.setHues(accentColorToUse, null);
		}
	}

	// Update the view
	function onUpdate(dc as Dc) as Void {
		var isHighPowerMode =
			System has :getDisplayMode
				? System.getDisplayMode() == System.DISPLAY_MODE_HIGH_POWER
				: false;
		if (isHighPowerMode) {
			_complicationTop.setColor(Graphics.COLOR_LT_GRAY);
			_complicationCenter.setColor(Graphics.COLOR_LT_GRAY);
			_complicationBottom.setColor(Graphics.COLOR_LT_GRAY);
		} else {
			_complicationTop.setColor(Graphics.COLOR_DK_GRAY);
			_complicationCenter.setColor(Graphics.COLOR_DK_GRAY);
			_complicationBottom.setColor(Graphics.COLOR_DK_GRAY);
		}

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() as Void {}

	// The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() as Void {}

	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() as Void {}

	public function notifyComplicationChanged() as Void {
		_settingsChanged = true;
	}
}
