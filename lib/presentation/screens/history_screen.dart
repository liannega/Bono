import 'package:flutter/material.dart';

class HistoryItem {
  final String title;
  final String? subtitle;
  final String code;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  HistoryItem({
    required this.title,
    this.subtitle,
    required this.code,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  // Convertir a Map para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'code': code,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'colorValue': color.value,
    };
  }

  // Crear desde Map para recuperación
  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      title: map['title'],
      subtitle: map['subtitle'],
      code: map['code'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      icon: IconData(
        map['iconCodePoint'],
        fontFamily: map['iconFontFamily'],
        fontPackage: map['iconFontPackage'],
      ),
      color: Color(map['colorValue']),
    );
  }
}