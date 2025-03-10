import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';


class UssdSimple {
  static const MethodChannel _channel = MethodChannel('ussd_simple');

  /// Envía un código USSD usando la SIM especificada
  /// 
  /// [code] es el código USSD a enviar (por ejemplo, "*123#")
  /// [subscriptionId] es el ID de la SIM (1 para la SIM principal, 2 para la secundaria)
  static Future<String?> sendUssd({
    required String code,
    int subscriptionId = 1,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('sendUssd', {
        'code': code,
        'subscriptionId': subscriptionId,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error al enviar código USSD: ${e.message}');
      return 'Error: ${e.message}';
    }
  }
}


class UssdService {
  static Future<String?> executeUssd(String code, {int subscriptionId = 1}) async {
    try {
      var status = await Permission.phone.request();
      if (!status.isGranted) {
        return 'Permiso denegado';
      }

      return await UssdSimple.sendUssd(code: code, subscriptionId: subscriptionId);
    } catch (e) {
      return 'Error al ejecutar USSD: $e';
    }
  }
}


