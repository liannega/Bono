import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

Future<void> saveThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  String themeModeString;

  switch (mode) {
    case ThemeMode.light:
      themeModeString = 'light';
      break;
    case ThemeMode.dark:
      themeModeString = 'dark';
      break;
    case ThemeMode.system:
    default:
      themeModeString = 'system';
      break;
  }

  await prefs.setString('theme_mode', themeModeString);
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}
