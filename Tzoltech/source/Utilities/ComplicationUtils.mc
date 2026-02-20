import Toybox.System;
import Toybox.Complications;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Weather;
import Toybox.Application;
import Toybox.WatchUi;

//! Complication locations
module ComplicationLocation {
	enum Value {
		LOC_TOP = "T",
		LOC_CENTER = "C",
		LOC_BOTTOM = "B",
		// LOC_RIGHT = "R",
		// LOC_LEFT = "L",
		LOC_R1 = "R1",
		LOC_R2 = "R2",
		LOC_R3 = "R3",
	}
}

module ComplicationUtils {
	// weather caching
	var _currWeatherCondition as Weather.Condition = Weather.CONDITION_UNKNOWN;
	var _currWeatherConditionStr as String = "--";
	var _forecast1Day as Weather.Condition = Weather.CONDITION_UNKNOWN;
	var _forecast1DayStr as String = "--";
	var _forecast2Day as Weather.Condition = Weather.CONDITION_UNKNOWN;
	var _forecast2DayStr as String = "--";
	var _forecast3Day as Weather.Condition = Weather.CONDITION_UNKNOWN;
	var _forecast3DayStr as String = "--";

	var _complicationIcons as Dictionary = {
		Complications.COMPLICATION_TYPE_BATTERY => Rez.Drawables.battery,
		Complications.COMPLICATION_TYPE_SOLAR_INPUT => Rez.Drawables.solar,
		Complications.COMPLICATION_TYPE_STRESS => Rez.Drawables.stress,
		Complications.COMPLICATION_TYPE_BODY_BATTERY => Rez.Drawables.body,
		Complications.COMPLICATION_TYPE_PULSE_OX => Rez.Drawables.pulseOx,
	};

	function getComplicationIcon(complicationType as Complications.Type) as BitmapResource? {
		if (_complicationIcons.hasKey(complicationType)) {
			return (
				Application.loadResource(_complicationIcons[complicationType] as ResourceId) as
				BitmapResource?
			);
		}
		return null;
	}

	//! Wrapped in try-catch since subscribing may fail due to different feature support per device
	function safeSubscribeToUpdates(id as Complications.Id?) as Void {
		if (id == null) {
			Utils.log("Unable to subscribe complication Id was null");
			return;
		}
		try {
			Complications.subscribeToUpdates(id);
			// Utils.log("subscribed to " + id.toString());
		} catch (e) {
			Utils.log("Unable to subscribe" + id.toString() + "\n" + e.getErrorMessage());
		}
	}

	function getWeatherString(w as Weather.Condition) as String {
		var wCondition =
			Application.loadResource(WeatherUtils.weatherConditionStrings[w]) as String;
		// Utils.log("Weather condition: " + wCondition);
		return wCondition.toUpper();
	}

	function _getBatteryTextString() as String {
		// Battery
		var systemStats = System.getSystemStats();
		var batteryInDays =
			systemStats has :batteryInDays ? systemStats.batteryInDays.format("%.1f") : "--";
		var batteryString = Lang.format("$1$% | $2$d", [
			systemStats.battery.format("%d"),
			batteryInDays,
		]);
		return batteryString;
	}

	function _getDateTextString() as String {
		// DATE
		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var todayString = Lang.format("$1$. $2$ $3$", [today.day_of_week, today.month, today.day]);
		return todayString.toUpper();
	}

	function getComplicationLabel(complicationId as Complications.Id) as String {
		try {
			var complication = Complications.getComplication(complicationId);
			var label = complication.shortLabel;
			if (label == null) {
				label = complication.longLabel;
			}
			if (label == null || label.length() > 7) {
				label = "";
			}
			var customLabel = getCustomCompLabel(complicationId.getType());

			if (customLabel != null) {
				label = customLabel;
			}
			return label.toUpper();
		} catch (e) {
			return "";
		}
	}

	function getFormattedCompStr(
		complicationId as Complications.Id,
		location as ComplicationLocation.Value
	) as String {
		var complication, label, value;

		try {
			complication = Complications.getComplication(complicationId);
			var complicationType = complicationId.getType();

			label = complication.shortLabel;
			if (label == null) {
				label = complication.longLabel;
			}
			if (label == null || label.length() > 7) {
				label = "";
			}

			var customLabel = getCustomCompLabel(complicationType);

			if (customLabel != null) {
				label = customLabel;
			}

			label = label.toUpper();

			var isWeatherRelated =
				complicationType.equals(Complications.COMPLICATION_TYPE_CURRENT_WEATHER) ||
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY) ||
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY) ||
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY);

			value = complication.value;

			if (value == null) {
				value = "--";
			} else if (value instanceof Float) {
				switch (complicationType) {
					case Complications.COMPLICATION_TYPE_ALTITUDE: //meters
						if (System.getDeviceSettings().elevationUnits == System.UNIT_STATUTE) {
							value *= 3.281;
							value = Lang.format("$1$ft", [value.format("%0.1f")]);
						} else {
							value = Lang.format("$1$m", [value.format("%0.1f")]);
						}
						break;
					case Complications.COMPLICATION_TYPE_SEA_LEVEL_PRESSURE: // there's no Unit_pressure
						value /= 1000; // convert to kPA
						value = Lang.format("$1$kPa", [value.format("%0.1f")]);
						break;
					case Complications.COMPLICATION_TYPE_CURRENT_TEMPERATURE: //celsius
						if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
							value = (value * 9) / 5 + 32;
						}
						break;
					case Complications.COMPLICATION_TYPE_WEEKLY_RUN_DISTANCE: //meters
					case Complications.COMPLICATION_TYPE_WEEKLY_BIKE_DISTANCE:
						if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
							value /= 1609;
						} else {
							value /= 1000;
						}
						break;
					case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K:
					case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K:
					case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON:
					case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON:
						if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
							var secondsPerMile = 0;
							if (value > 0.0) {
								secondsPerMile = (1609.34 / value).toNumber();
							}
							var minutes = secondsPerMile / 60;
							var secs = (secondsPerMile % 60).format("%02d");
							value = Lang.format("$1$:$2$/mi", [minutes, secs]);
						} else {
							var secondsPerMeter = 0;
							if (value > 0.0) {
								secondsPerMeter = (1000 / value).toNumber();
							}
							var minutes = secondsPerMeter / 60;
							var secs = (secondsPerMeter % 60).format("%02d");
							value = Lang.format("$1$:$2$/km", [minutes, secs]);
						}
						break;
					default:
						break;
				}
				if (value instanceof Float) {
					value = value.format("%.1f");
				}
			} else if (value instanceof Number && !isWeatherRelated) {
				var hours, minutes, seconds;
				switch (complicationType) {
					case Complications.COMPLICATION_TYPE_SUNRISE:
					case Complications.COMPLICATION_TYPE_SUNSET:
						hours = value / 3600;
						minutes = (value % 3600) / 60;
						var suffix = "";
						if (!System.getDeviceSettings().is24Hour) {
							suffix = "AM";
							if (hours >= 12) {
								suffix = "PM";
								if (hours > 12) {
									hours -= 12;
								}
							}
						}
						value = Lang.format("$1$:$2$$3$", [hours, minutes.format("%0d"), suffix]);
						break;
					case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_5K:
					case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_10K:
					case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON:
					case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON:
						hours = (value / 3600).format("%02d"); // integer division
						minutes = ((value / 60) % 60).format("%02d"); // minutes remainder
						seconds = (value % 60).format("%02d"); // leftover seconds
						value = Lang.format("$1$:$2$:$3$", [hours, minutes, seconds]);
						break;
					case Complications.COMPLICATION_TYPE_RECOVERY_TIME:
						value /= 60;
						break;
					case Complications.COMPLICATION_TYPE_BATTERY:
						value = _getBatteryTextString();
						break;
					default:
						break;
				}
			} else if (value instanceof String) {
				switch (complicationType) {
					case Complications.COMPLICATION_TYPE_DATE:
						value = _getDateTextString();
						break;
					default:
						value = value.toUpper();
						break;
				}
			} else if (complicationType.equals(Complications.COMPLICATION_TYPE_CURRENT_WEATHER)) {
				var currCondition = value as Weather.Condition;

				if (!_currWeatherCondition.equals(currCondition)) {
					_currWeatherCondition = currCondition;
					_currWeatherConditionStr = getWeatherString(currCondition); // cache value
					value = _currWeatherConditionStr;
				} else {
					value = _currWeatherConditionStr;
				}
			} else if (
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY)
			) {
				var forecast = value as Weather.Condition;

				if (!_forecast1Day.equals(forecast)) {
					_forecast1Day = forecast;
					_forecast1DayStr = getWeatherString(forecast); // cache value
					value = _forecast1DayStr;
				} else {
					value = _forecast1DayStr;
				}
			} else if (
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY)
			) {
				var forecast = value as Weather.Condition;

				if (!_forecast2Day.equals(forecast)) {
					_forecast2Day = forecast;
					_forecast2DayStr = getWeatherString(forecast); // cache value
					value = _forecast2DayStr;
				} else {
					value = _forecast2DayStr;
				}
			} else if (
				complicationType.equals(Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY)
			) {
				var forecast = value as Weather.Condition;

				if (!_forecast3Day.equals(forecast)) {
					_forecast3Day = forecast;
					_forecast3DayStr = getWeatherString(forecast); // cache value
					value = _forecast3DayStr;
				} else {
					value = _forecast3DayStr;
				}
			} else if (value instanceof Double) {
				// likely only happens for custom complications
				value = value.format("%.3f");
			} else if (value instanceof Long) {
				value = value.format("%.3E");
			}
		} catch (ComplicationNotFoundException) {
			label = "";
			value = "--";
		}
		var valStr = "$1$";
		var valLabelStr = "$1$ $2$";
		var formatted = label.equals("")
			? Lang.format(valStr, [value])
			: Lang.format(valLabelStr, [label, value]);

		return formatted;

		// switch (location) {
		// 	case ComplicationLocation.LOC_TOP:
		// 		_topComplicationText = formatted;
		// 		break;
		// 	case ComplicationLocation.LOC_BOTTOM:
		// 		_bottomComplicationText = formatted;
		// 		break;
		// 	case ComplicationLocation.LOC_RIGHT:
		// 		_rightComplicationText = formatted;
		// 		break;
		// 	case ComplicationLocation.LOC_LEFT:
		// 		_leftComplicationText = formatted;
		// 		break;
		// 	default:
		// 		break;
		// }
	}

	function getComplicationValue(complicationId as Complications.Id) as Number {
		try {
			var data = Complications.getComplication(complicationId);
			var value = 0;
			// Doing it this way to avoid casting every to Number very time
			if (data.value instanceof Number) {
				value = data.value as Number;
			}
			return value;
		} catch (e) {
			Utils.log("Error in onComplication Changed: " + e);
			return 0;
		}
	}

	function getCustomCompLabel(complicationType as Complications.Type) as String? {
		var currLang = System.getDeviceSettings().systemLanguage;

		// if (!currLang.equals(System.LANGUAGE_SPA) && !currLang.equals(System.LANGUAGE_ENG)) {
		// 	return null;
		// }

		var label = null;
		// Insentive to decrease len for devices that don't support radial text
		// NOTE: this may need to change as support for other languages increases
		switch (complicationType) {
			case Complications.COMPLICATION_TYPE_CURRENT_WEATHER:
				label = ""; // currLang.equals(System.LANGUAGE_SPA) ? "CLIMA" : "WX";
				break;
			case Complications.COMPLICATION_TYPE_FORECAST_WEATHER_1DAY:
				label = "1";
				break;
			case Complications.COMPLICATION_TYPE_FORECAST_WEATHER_2DAY:
				label = "2";
				break;
			case Complications.COMPLICATION_TYPE_FORECAST_WEATHER_3DAY:
				label = "3";
				break;
			case Complications.COMPLICATION_TYPE_BATTERY:
				label = "BAT";
				break;
			case Complications.COMPLICATION_TYPE_INTENSITY_MINUTES:
				label = currLang.equals(System.LANGUAGE_SPA) ? "MIN INT" : "INT MIN";
				break;
			case Complications.COMPLICATION_TYPE_CALORIES:
				label = "C";
				break;
			case Complications.COMPLICATION_TYPE_SUNRISE:
				label = currLang.equals(System.LANGUAGE_SPA) ? "ALBA" : "RISE";
				break;
			case Complications.COMPLICATION_TYPE_SUNSET:
				label = currLang.equals(System.LANGUAGE_SPA) ? "OCASO" : "SET";
				break;
			case Complications.COMPLICATION_TYPE_VO2MAX_RUN:
				label = currLang.equals(System.LANGUAGE_SPA) ? "VO2 C" : "VO2 R";
				break;
			case Complications.COMPLICATION_TYPE_VO2MAX_BIKE:
				label = "VO2 B";
				break;
			case Complications.COMPLICATION_TYPE_RECOVERY_TIME:
				label = "R";
				break;
			case Complications.COMPLICATION_TYPE_RESPIRATION_RATE:
				label = "BRPM";
				break;
			case Complications.COMPLICATION_TYPE_PULSE_OX:
				label = "SpO2";
				break;
			case Complications.COMPLICATION_TYPE_DATE:
			case Complications.COMPLICATION_TYPE_BATTERY:
			case Complications.COMPLICATION_TYPE_WEEKDAY_MONTHDAY:
				label = "";
				break;
			case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_5K:
			case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_5K:
				label = "5K";
				break;
			case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_10K:
			case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_10K:
				label = "10K";
				break;
			case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_HALF_MARATHON:
			case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_HALF_MARATHON:
				label = "HM";
				break;
			case Complications.COMPLICATION_TYPE_RACE_PREDICTOR_MARATHON:
			case Complications.COMPLICATION_TYPE_RACE_PACE_PREDICTOR_MARATHON:
				label = "M";
				break;
			case Complications.COMPLICATION_TYPE_HIGH_LOW_TEMPERATURE:
				label = "T";
				break;
			default:
				break;
		}
		return label;
	}
}
