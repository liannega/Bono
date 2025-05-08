import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';

class UssdExecutorService {
  static Future<bool> executeUssdCodeDirectly({
    required String code,
    required MenuItems item,
    required Function(bool) setExecuting,
    required Function(String?) setStatusMessage,
  }) async {
    setExecuting(true);

    try {
      var ussdCode = code.trim();
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      final success = await UssdService.executeUssd(ussdCode);

      if (success) {
        await HistoryService.addToHistory(item, ussdCode);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      setExecuting(false);
    }
  }
}
