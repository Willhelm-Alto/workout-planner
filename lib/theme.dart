import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =========================== Color schemes ===========================

/// Light scheme. The pinned roles hold the literal colors the app already
/// ships, so swapping an inline color for its role is a no-op in light mode.
final ColorScheme _lightScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.light,

  // shade700 (#1976D2) instead of shade500: white on #2196F3 is 3.12:1 and
  // fails WCAG AA on the filled buttons; white on #1976D2 is 4.60:1.
  primary: Colors.blue.shade700,
  onPrimary: Colors.white,

  // The blue.shade50 / blue.shade700 chip pair, promoted to a role.
  secondaryContainer: Colors.blue.shade50,
  onSecondaryContainer: Colors.blue.shade800,

  // Every Card outline and hairline border in the app is grey.shade300.
  outlineVariant: Colors.grey.shade300,

  // The "exercising" ring accent. No Material widget defaults to tertiary,
  // so repurposing it costs nothing.
  tertiary: Colors.orange.shade800,
  onTertiary: Colors.white,
);

/// Dark scheme. Nothing to preserve here, so M3's tonal values are kept
/// except for the brand anchor and the work accent.
final ColorScheme _darkScheme = ColorScheme.fromSeed(
  seedColor: Colors.blue,
  brightness: Brightness.dark,

  primary: Colors.blue.shade200,
  onPrimary: const Color(0xFF00335B),

  tertiary: Colors.orange.shade300,
  onTertiary: const Color(0xFF3E2000),
);

// =============================== Themes ==============================

abstract final class AppTheme {
  static final ThemeData light = _build(_lightScheme);
  static final ThemeData dark = _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    // Two steps: chipTheme needs base.textTheme, which only exists after
    // ThemeData has resolved typography against the scheme.
    final ThemeData base = ThemeData(colorScheme: scheme);
    final TextTheme text = base.textTheme;
    final bool isLight = scheme.brightness == Brightness.light;

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarThemeData(
        backgroundColor: isLight ? scheme.primary : scheme.surfaceContainer,
        foregroundColor: isLight ? scheme.onPrimary : scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // labelStyle must be built from `text`: ChipThemeData.labelStyle
      // replaces the M3 default instead of merging with it, so a bare
      // TextStyle(color:) would drop labelLarge's size and weight.
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        labelStyle: text.labelLarge?.copyWith(
          color: scheme.onSecondaryContainer,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),

      inputDecorationTheme: InputDecorationThemeData(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        // Required. Without it the labelStyle above also paints the floating
        // label, killing the "label turns primary on focus" affordance.
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.error)) {
            return TextStyle(color: scheme.error);
          }
          if (states.contains(WidgetState.focused)) {
            return TextStyle(color: scheme.primary);
          }
          return TextStyle(color: scheme.onSurfaceVariant);
        }),
      ),

      // Explicit, because M3's default linear track is secondaryContainer,
      // which is pinned to blue.shade50 here — a blue track under a blue bar.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
      ),
    );
  }
}

// ============================= Controller ============================

class ThemeController extends ChangeNotifier {
  static ThemeController? _instance; //instância da própria classe

  /// Lands on disk as `flutter.workout_planner.theme_mode` once the plugin
  /// applies its default prefix.
  static const String _prefsKey = 'workout_planner.theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool wasInitialized = false;

  ThemeController._(); //construtor com nome "_"

  factory ThemeController() {
    _instance ??= ThemeController._();
    return _instance!;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Reads the saved choice, falling back to the platform brightness when
  /// nothing was ever saved.
  Future<void> load() async {
    if (wasInitialized) return;

    String? saved;
    try {
      final prefs = await SharedPreferences.getInstance();
      saved = prefs.getString(_prefsKey);
    } catch (_) {
      saved = null; // a prefs failure must never block the first frame
    }

    // An explicit switch, not ThemeMode.values.byName: byName throws on an
    // unknown string and would accept 'system', which this app does not use.
    _themeMode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ =>
        PlatformDispatcher.instance.platformBrightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
    };

    wasInitialized = true;
    notifyListeners();
  }

  /// Flips the mode. Repaints immediately; the write trails the tap.
  Future<void> toggle() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _themeMode.name);
    } catch (_) {
      // Persistence is best-effort; the in-memory flip already happened.
    }
  }
}
