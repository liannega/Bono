import 'package:flutter/services.dart';

class UssdService {
  static const MethodChannel _channel = MethodChannel('com.example.bono/ussd');

  
  static Future<bool> hasCallPermission() async {
    try {
      final bool result = await _channel.invokeMethod('hasCallPermission');
      return result;
    } on PlatformException catch (e) {
      print('Error al verificar permiso: ${e.message}');
      return false;
    }
  }

 
  static Future<void> requestCallPermission() async {
    try {
      await _channel.invokeMethod('requestCallPermission');
    } on PlatformException catch (e) {
      print('Error al solicitar permiso: ${e.message}');
    }
  }


  static Future<bool> executeUssd(String code) async {
    try {
    
      bool hasPermission = await hasCallPermission();
      if (!hasPermission) {
        await requestCallPermission();
        hasPermission = await hasCallPermission();
        if (!hasPermission) {
          return false;
        }
      }

      var ussdCode = code.trim();

      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }


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
