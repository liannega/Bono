import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WidgetService {
  static const MethodChannel _channel =
      MethodChannel('com.example.bono/widget');
  static const MethodChannel _ussdChannel =
      MethodChannel('com.example.bono/ussd');

  // Activar el widget
  static Future<void> enableWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('widget_enabled', true);
      await _channel.invokeMethod('enableWidget');
      print('Widget activado correctamente');
    } catch (e) {
      print('Error al activar widget: $e');
    }
  }

  // Desactivar el widget
  static Future<void> disableWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('widget_enabled', false);
      await _channel.invokeMethod('disableWidget');
      print('Widget desactivado correctamente');
    } catch (e) {
      print('Error al desactivar widget: $e');
    }
  }

  // Activar/desactivar WiFi
  static Future<void> toggleWifi() async {
    try {
      await _channel.invokeMethod('toggleWifi');
    } catch (e) {
      print('Error al cambiar WiFi: $e');
    }
  }

  // Activar/desactivar datos móviles
  static Future<void> toggleMobileData() async {
    try {
      await _channel.invokeMethod('toggleMobileData');
    } catch (e) {
      print('Error al cambiar datos móviles: $e');
    }
  }

  // Ejecutar código USSD
  static Future<void> executeUssdCode(String code) async {
    try {
      await _ussdChannel.invokeMethod('executeUssd', {'code': code});
    } catch (e) {
      print('Error al ejecutar código USSD: $e');
    }
  }
}
