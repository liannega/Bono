import 'dart:convert';
import 'package:bono/presentation/screens/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bono/presentation/widgets/shared/items.dart';

class HistoryService {
  static const String _historyKey = 'ussd_history';
  static List<HistoryItem> _cachedHistory = [];
  static bool _isInitialized = false;

  // Inicializar el servicio cargando el historial desde SharedPreferences
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    _cachedHistory = historyJson
        .map((item) => HistoryItem.fromMap(json.decode(item)))
        .toList();

    _isInitialized = true;
  }

  // Obtener el historial completo
  static Future<List<HistoryItem>> getHistory() async {
    await initialize();
    return List.from(_cachedHistory);
  }

  // Agregar un elemento al historial
  static Future<void> addToHistory(MenuItems item, String code) async {
    await initialize();

    final historyItem = HistoryItem(
      title: item.title,
      subtitle: item.subtitle,
      code: code,
      timestamp: DateTime.now(),
      icon: item.icon,
      color: item.color,
    );

    // Agregar al inicio de la lista (más reciente primero)
    _cachedHistory.insert(0, historyItem);

    // Limitar el historial a 50 elementos
    if (_cachedHistory.length > 50) {
      _cachedHistory = _cachedHistory.sublist(0, 50);
    }

    // Guardar en SharedPreferences
    await _saveHistory();
  }

  // Limpiar el historial
  static Future<void> clearHistory() async {
    _cachedHistory.clear();
    await _saveHistory();
  }

  // Guardar el historial en SharedPreferences
  static Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _cachedHistory.map((item) => json.encode(item.toMap())).toList();

    await prefs.setStringList(_historyKey, historyJson);
  }
}
