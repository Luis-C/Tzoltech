import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TzoltechApp extends Application.AppBase {
	private var _view as TzoltechView?;

	function initialize() {
		AppBase.initialize();
	}

	// onStart() is called on application start up
	function onStart(state as Dictionary?) as Void {}

	// onStop() is called when your application is exiting
	function onStop(state as Dictionary?) as Void {}

	// Return the initial view of your application here
	function getInitialView() as [Views] or [Views, InputDelegates] {
		_view = new TzoltechView();
		return [_view];
	}

	function notifyComplicationChanged() as Void {
		if (_view != null) {
			_view.notifyComplicationChanged();
		}
	}

	//! Return the settings view and delegate
	//! @return Array Pair [View, Delegate]
	public function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
		// return [new $.StatsRadarSettingsView(), new $.StatsRadarSettingsDelegate()];
		return [new SettingsMenu(), new SettingsMenuDelegate()];
	}
}

function getApp() as TzoltechApp {
	return Application.getApp() as TzoltechApp;
}
