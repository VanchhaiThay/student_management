import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _themeKey = 'theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system; // Default until loaded
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey);
    if (isDark != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final isCurrentlyDark = state == ThemeMode.dark || 
        (state == ThemeMode.system && 
         WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
