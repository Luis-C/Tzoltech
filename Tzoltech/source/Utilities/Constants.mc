module StorageKeys {
	enum Value {
		KEY_USE_CONFIG = "KUC", // useConfig
		KEY_ACCENT_COLOR = "KAC", //accentColor
		KEY_ACCENT_COLOR_LABEL = "KACL", // accentColorLabel
		KEY_DATA_COLOR = "KDC", //dataColorLabel
		KEY_DATA_COLOR_LABEL = "KDCL", // dataColorLabel
		KEY_INVERT_RECOVERY = "KIR", // invertRecovery
		KEY_INVERT_STRESS = "KIR", // invertStress
		KEY_WHITE_BKG = "WBKG", // isBkgWhite

		KEY_VISIBILITY_FLAGS = "KVF", // visibilityFlags
	}
}

module VisibilityFlags {
	enum Value {
		FLAG_TOP = 1 << 0,
		FLAG_CENTER = 1 << 1,
		FLAG_BOTTOM = 1 << 2,
		FLAG_LEFT = 1 << 3,
		FLAG_RIGHT = 1 << 4,
	}
}

// var flags = 0;

// // Set a flag
// flags |= FLAG_B;

// // Clear a flag
// flags &= ~FLAG_B;

// // Toggle a flag
// flags ^= FLAG_C;

// // Check a flag
// if ((flags & FLAG_A) != 0) {
//     // FLAG_A is set
// }
