import 'dart:convert';
import 'package:bono/models/history_model.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Verificar si un elemento ya existe en el historial
  static Future<bool> itemExists(String code) async {
    await initialize();

    // Normalizar el código para la comparación
    var normalizedCode = code.trim();
    if (!normalizedCode.startsWith("*") && !normalizedCode.startsWith("#")) {
      normalizedCode = "*$normalizedCode";
    }
    if (!normalizedCode.endsWith("#")) {
      normalizedCode = "$normalizedCode#";
    }

    // Buscar el elemento por código
    return _cachedHistory.any((item) {
      var itemCode = item.code.trim();
      if (!itemCode.startsWith("*") && !itemCode.startsWith("#")) {
        itemCode = "*$itemCode";
      }
      if (!itemCode.endsWith("#")) {
        itemCode = "$itemCode#";
      }
      return itemCode == normalizedCode;
    });
  }

  // Agregar un elemento al historial o actualizar si ya existe
  static Future<void> addToHistory(MenuItems item, String code) async {
    await initialize();

    // Normalizar el código para la comparación
    var normalizedCode = code.trim();
    if (!normalizedCode.startsWith("*") && !normalizedCode.startsWith("#")) {
      normalizedCode = "*$normalizedCode";
    }
    if (!normalizedCode.endsWith("#")) {
      normalizedCode = "$normalizedCode#";
    }

    // Buscar si ya existe un elemento con el mismo código
    final existingIndex = _cachedHistory.indexWhere((historyItem) {
      var itemCode = historyItem.code.trim();
      if (!itemCode.startsWith("*") && !itemCode.startsWith("#")) {
        itemCode = "*$itemCode";
      }
      if (!itemCode.endsWith("#")) {
        itemCode = "$itemCode#";
      }
      return itemCode == normalizedCode;
    });

    if (existingIndex != -1) {
      // Si existe, eliminar el elemento antiguo
      _cachedHistory.removeAt(existingIndex);
    }

    // Crear un nuevo elemento con la fecha actual
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

  // Método para actualizar un elemento del historial
  static Future<void> updateHistoryItem(
      HistoryItem oldItem, HistoryItem newItem) async {
    await initialize();

    // Buscar el índice del elemento antiguo
    final index = _cachedHistory.indexWhere(
        (item) => item.title == oldItem.title && item.code == oldItem.code);

    if (index != -1) {
      // Eliminar el elemento antiguo
      _cachedHistory.removeAt(index);

      // Insertar el nuevo elemento en la primera posición
      _cachedHistory.insert(0, newItem);

      // Guardar en SharedPreferences
      await _saveHistory();
    }
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
