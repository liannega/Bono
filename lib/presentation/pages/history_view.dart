

import 'package:bono/services/history_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/models/history_model.dart';

class HistoryView extends StatefulWidget {
  final Function(String) onStatusMessage;

  const HistoryView({
    super.key,
    required this.onStatusMessage,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;
  bool _isExecutingUssd = false;

  // Canal para USSD
  static const ussdPlatform = MethodChannel('com.example.bono/ussd');

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final history = await HistoryService.getHistory();

    setState(() {
      _historyItems = history;
      _isLoading = false;
    });
  }

  Future<void> _executeUssdFromHistory(HistoryItem item) async {
    if (_isExecutingUssd) return;

    setState(() {
      _isExecutingUssd = true;
    });

    try {
      if (item.title == "Asterisco 99") {
        if (mounted) {
          await _updateHistoryItemTimestamp(item);
          await _loadHistory();

          context.go('/asterisco99');
        }
        return;
      } else if (item.title == "Mi número oculto") {
        if (mounted) {
          await _updateHistoryItemTimestamp(item);
          await _loadHistory();

          context.go('/numero-oculto');
        }
        return;
      } else if (item.title == "Números útiles") {
        if (mounted) {
          await _updateHistoryItemTimestamp(item);
          await _loadHistory();

          context.go('/numeros-utiles');
        }
        return;
      } else if (item.title == "Transferir Saldo") {
        if (mounted) {
          await _updateHistoryItemTimestamp(item);
          await _loadHistory();

          context.go('/transferir-saldo');
        }
        return;
      } else if (item.title.contains("Atención al cliente") ||
          item.title.contains("Línea Antidrogas") ||
          item.title.contains("Ambulancias") ||
          item.title.contains("Bomberos") ||
          item.title.contains("Policía") ||
          item.title.contains("Salvamento Marítimo") ||
          item.title.contains("Cubacel Info")) {
        try {
          await _updateHistoryItemTimestamp(item);
          await _loadHistory();

          await ussdPlatform.invokeMethod('makeDirectCall', {
            'phoneNumber': item.code.replaceAll("#", ""),
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al realizar la llamada: $e',
                  style: GoogleFonts.montserrat(
                    letterSpacing: -0.3,
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return;
      }

      var ussdCode = item.code.trim();
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      final success = await UssdService.executeUssd(ussdCode);

      if (!mounted) return;

      if (success) {
        await _updateHistoryItemTimestamp(item);
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.montserrat(
                letterSpacing: -0.3,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExecutingUssd = false;
        });
      }
    }
  }

  Future<void> _updateHistoryItemTimestamp(HistoryItem item) async {
    final updatedItem = HistoryItem(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      code: item.code,
      timestamp: DateTime.now(),
    );

    await HistoryService.updateHistoryItem(item, updatedItem);
  }

  Future<void> _clearHistory() async {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Limpiar historial',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas limpiar todo el historial?',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 14,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Limpiar',
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await HistoryService.clearHistory();
      await _loadHistory();
      widget.onStatusMessage("Historial eliminado");
      // Limpiar el mensaje después de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onStatusMessage("");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_historyItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay historial',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                color: Colors.grey,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las acciones que realices aparecerán aquí',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey,
                letterSpacing: -0.3,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: InkWell(
              onTap: _clearHistory,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Limpiar',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.blue,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _historyItems.length,
            itemBuilder: (context, index) {
              final item = _historyItems[index];
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

              final isTransfer = item.title == "Transferir Saldo";

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.05),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _executeUssdFromHistory(item),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: item.color.withOpacity(0.3),
                    highlightColor: item.color.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: item.color,
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                if (item.subtitle != null && !isTransfer)
                                  Text(
                                    item.subtitle!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      letterSpacing: -0.3,
                                      height: 1.1,
                                    ),
                                  ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.title == "Transferir Saldo"
                                ? "*234"
                                : item.code,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: item.color,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
