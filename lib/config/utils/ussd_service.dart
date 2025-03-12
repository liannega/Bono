import 'package:flutter/services.dart';

class UssdService {
  static const MethodChannel _channel = MethodChannel('com.example.bono/ussd');

  // Verificar si tiene permiso de llamada
  static Future<bool> hasCallPermission() async {
    try {
      final bool result = await _channel.invokeMethod('hasCallPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error al verificar permiso: ${e.message}');
      return false;
    }
  }

  // Solicitar permiso de llamada
  static Future<void> requestCallPermission() async {
    try {
      await _channel.invokeMethod('requestCallPermission');
    } on PlatformException catch (e) {
      print('Error al solicitar permiso: ${e.message}');
    }
  }

  // Método para ejecutar códigos USSD
  static Future<bool> executeUssd(String code) async {
    try {
      // Verificar permiso
      bool hasPermission = await hasCallPermission();
      if (!hasPermission) {
        await requestCallPermission();
        hasPermission = await hasCallPermission();
        if (!hasPermission) {
          return false;
        }
      }

      // Formatear el código USSD correctamente
      var ussdCode = code.trim();

      // Asegurarse de que el código tenga el formato correcto
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      // Ejecutar el código USSD
      final bool? result = await _channel.invokeMethod('executeUssd', {
        'code': ussdCode,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al ejecutar USSD: ${e.message}');
      return false;
    }
  }
}
