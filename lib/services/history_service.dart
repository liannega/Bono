import 'dart:convert';
import 'package:bono/models/history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:flutter/material.dart';

class HistoryService {
  static const String _historyKey = 'ussd_history';
  static List<HistoryItem> _cachedHistory = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];

    _cachedHistory = historyJson
        .map((item) => HistoryItem.fromMap(json.decode(item)))
        .toList();

    _isInitialized = true;
  }

  static Future<List<HistoryItem>> getHistory() async {
    await initialize();
    return List.from(_cachedHistory);
  }

  static Future<bool> itemExists(String code) async {
    await initialize();

    var normalizedCode = code.trim();
    if (!normalizedCode.startsWith("*") && !normalizedCode.startsWith("#")) {
      normalizedCode = "*$normalizedCode";
    }
    if (!normalizedCode.endsWith("#")) {
      normalizedCode = "$normalizedCode#";
    }

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

  static Future<void> addToHistory(MenuItems item, String code) async {
    await initialize();

    var normalizedCode = code.trim();
    if (!normalizedCode.startsWith("*") && !normalizedCode.startsWith("#")) {
      normalizedCode = "*$normalizedCode";
    }
    if (!normalizedCode.endsWith("#")) {
      normalizedCode = "$normalizedCode#";
    }

    bool isSpecialCase =
        item.title == "Asterisco 99" || item.title == "Mi número oculto";

    if (isSpecialCase) {
      final existingIndex = _cachedHistory
          .indexWhere((historyItem) => historyItem.title == item.title);

      if (existingIndex != -1) {
        _cachedHistory.removeAt(existingIndex);
      }
    } else {
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
        _cachedHistory.removeAt(existingIndex);
      }
    }

    Color itemColor = item.color;

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

    if (item.title == "Transferir Saldo") {
      itemColor = Colors.orange;
    }

    final historyItem = HistoryItem(
      title: item.title,
      subtitle: item.subtitle,
      code: code,
      timestamp: DateTime.now(),
      icon: item.icon,
      color: itemColor,
    );

    _cachedHistory.insert(0, historyItem);

    if (_cachedHistory.length > 50) {
      _cachedHistory = _cachedHistory.sublist(0, 50);
    }

    await _saveHistory();
  }

  static Future<void> updateHistoryItem(
      HistoryItem oldItem, HistoryItem newItem) async {
    await initialize();

    bool isSpecialCase =
        oldItem.title == "Asterisco 99" || oldItem.title == "Mi número oculto";

    int index;

    if (isSpecialCase) {
      index = _cachedHistory.indexWhere((item) => item.title == oldItem.title);
    } else {
      index = _cachedHistory.indexWhere(
          (item) => item.title == oldItem.title && item.code == oldItem.code);
    }

    if (index != -1) {
      _cachedHistory.removeAt(index);

      _cachedHistory.insert(0, newItem);

      await _saveHistory();
    }
  }

  static Future<void> clearHistory() async {
    _cachedHistory.clear();
    await _saveHistory();
  }

  static Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _cachedHistory.map((item) => json.encode(item.toMap())).toList();

    await prefs.setStringList(_historyKey, historyJson);
  }
}
