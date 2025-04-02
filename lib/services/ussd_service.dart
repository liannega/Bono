import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';

/// Servicio para ejecutar códigos USSD y manejar el estado de ejecución
class UssdExecutorService {
  /// Ejecuta un código USSD directamente sin confirmación
  static Future<bool> executeUssdCodeDirectly({
    required String code,
    required MenuItems item,
    required Function(bool) setExecuting,
    required Function(String?) setStatusMessage,
  }) async {
    // Evitar múltiples ejecuciones simultáneas
    setExecuting(true);
    // No mostrar mensajes de estado
    // setStatusMessage("Ejecutando código USSD...");

    try {
      // Asegurarse de que el código tenga el formato correcto
      var ussdCode = code.trim();
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      // Ejecutar el código USSD usando el servicio nativo
      final success = await UssdService.executeUssd(ussdCode);

      if (success) {
        // No mostrar mensajes de estado
        // setStatusMessage("Código USSD ejecutado correctamente");
        // Agregar al historial si se ejecutó correctamente
        await HistoryService.addToHistory(item, ussdCode);
        return true;
      } else {
        // No mostrar mensajes de estado
        // setStatusMessage("Error al ejecutar el código USSD");
        return false;
      }
    } catch (e) {
      // No mostrar mensajes de estado
      // setStatusMessage("Error: ${e.toString()}");
      return false;
    } finally {
      setExecuting(false);

      // No programar la limpieza del mensaje
      // Future.delayed(const Duration(seconds: 3), () {
      //   setStatusMessage(null);
      // });
    }
  }
}
