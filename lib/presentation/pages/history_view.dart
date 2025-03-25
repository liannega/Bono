import 'package:bono/services/history_service.dart';
import 'package:flutter/material.dart';
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

    widget.onStatusMessage("Ejecutando código USSD...");

    try {
      // Asegurarse de que el código tenga el formato correcto
      var ussdCode = item.code.trim();
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      // Ejecutar el código USSD
      final success = await UssdService.executeUssd(ussdCode);

      if (!mounted) return;

      if (success) {
        widget.onStatusMessage("Código USSD ejecutado correctamente");

        // No agregamos al historial cuando se ejecuta desde la vista de historial
        // Solo actualizamos la fecha del elemento actual
        await _updateHistoryItemTimestamp(item);
        await _loadHistory();
      } else {
        widget.onStatusMessage("Error al ejecutar el código USSD");
      }
    } catch (e) {
      if (mounted) {
        widget.onStatusMessage("Error: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExecutingUssd = false;
        });

        // Limpiar el mensaje después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onStatusMessage("");
          }
        });
      }
    }
  }

  // Método para actualizar la fecha de un elemento del historial
  Future<void> _updateHistoryItemTimestamp(HistoryItem item) async {
    // Crear un nuevo elemento con la misma información pero con la fecha actual
    final updatedItem = HistoryItem(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      code: item.code,
      timestamp: DateTime.now(),
    );

    // Eliminar el elemento antiguo y agregar el actualizado
    await HistoryService.updateHistoryItem(item, updatedItem);
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text(
            '¿Estás seguro de que deseas limpiar todo el historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 166, 213, 245),
            ),
            child: const Text('Limpiar'),
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las acciones que realices aparecerán aquí',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Botón para limpiar historial
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _clearHistory,
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Limpiar historial'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 166, 213, 245),
            ),
          ),
        ),

        // Lista de historial
        Expanded(
          child: ListView.builder(
            itemCount: _historyItems.length,
            itemBuilder: (context, index) {
              final item = _historyItems[index];
              final formattedDate =
                  DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Card(
                  color: Colors.grey.withOpacity(0.1),
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
                                    color: Colors.white,
                                  ),
                                ),
                                if (item.subtitle != null)
                                  Text(
                                    item.subtitle!,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.code,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: item.color,
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
