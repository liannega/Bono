import 'dart:convert';
import 'package:bono/models/history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:flutter/material.dart';

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

    // Casos especiales para Asterisco 99 y Mi número oculto
    bool isSpecialCase =
        item.title == "Asterisco 99" || item.title == "Mi número oculto";

    // Si es un caso especial, buscar por título en lugar de código
    if (isSpecialCase) {
      // Buscar si ya existe un elemento con el mismo título
      final existingIndex = _cachedHistory
          .indexWhere((historyItem) => historyItem.title == item.title);

      if (existingIndex != -1) {
        // Si existe, eliminar el elemento antiguo
        _cachedHistory.removeAt(existingIndex);
      }
    } else {
      // Para otros casos, buscar por código como antes
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
    }

    // Determinar el color correcto para el historial
    Color itemColor = item.color;

    // Si es un elemento relacionado con llamadas, usar verde en el historial
    if (item.title == "Asterisco 99" ||
        item.title == "Mi número oculto" ||
        item.title == "Gestionar Llamadas" ||
        item.title.contains("Atención al cliente") ||
        item.title.contains("Línea Antidrogas") ||
        item.title.contains("Ambulancias") ||
        item.title.contains("Bomberos") ||
        item.title.contains("Policía") ||
        item.title.contains("Salvamento Marítimo") ||
        item.title.contains("Cubacel Info")) {
      itemColor = Colors.green;
    }

    // Si es una transferencia de saldo, usar naranja
    if (item.title == "Transferir Saldo") {
      itemColor = Colors.orange;
    }

    // Crear un nuevo elemento con la fecha actual
    final historyItem = HistoryItem(
      title: item.title,
      subtitle: item.subtitle,
      code: code,
      timestamp: DateTime.now(),
      icon: item.icon,
      color: itemColor, // Usar el color determinado
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

    // Casos especiales para Asterisco 99 y Mi número oculto
    bool isSpecialCase =
        oldItem.title == "Asterisco 99" || oldItem.title == "Mi número oculto";

    int index;

    if (isSpecialCase) {
      // Buscar por título para casos especiales
      index = _cachedHistory.indexWhere((item) => item.title == oldItem.title);
    } else {
      // Buscar por título y código para casos normales
      index = _cachedHistory.indexWhere(
          (item) => item.title == oldItem.title && item.code == oldItem.code);
    }

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
