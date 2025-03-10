import 'package:flutter/services.dart';

class UssdSimple {
  static const MethodChannel _channel = MethodChannel('ussd_simple');

  /// Envía un código USSD usando la SIM especificada.
  ///
  /// [code] es el código USSD a enviar (por ejemplo, "*123#").
  /// [subscriptionId] es el ID de la SIM (1 para la SIM principal, 2 para la secundaria).
  ///
  /// Retorna `true` si el código USSD se envió correctamente, o `false` si hubo un error.
  static Future<bool> sendUssd({
    required String code,
    int subscriptionId = 1,
  }) async {
    try {
      // Validar el código USSD
      if (!code.startsWith('*') || !code.endsWith('#')) {
        throw FormatException('El código USSD debe comenzar con * y terminar con #');
      }

      // Enviar el código USSD al plugin nativo
      final result = await _channel.invokeMethod<bool>('sendUssd', {
        'code': code,
        'subscriptionId': subscriptionId,
      });

      // Retornar el resultado (true si fue exitoso, false si hubo un error)
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error al enviar código USSD: ${e.message}');
      return false;
    } catch (e) {
      print('Error inesperado al enviar código USSD: $e');
      return false;
    }
  }
}