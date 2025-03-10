import 'package:bono/presentation/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmenuPage extends StatelessWidget {
  final String title;
  final List<MenuItems> items;

  const SubmenuPage({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () => _handleItemTap(context, item),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      item.icon,
                      color: Colors.white,
                      size: 28,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        if (item.subtitle != null)
                          Text(
                            item.subtitle!,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (item.hasSubmenu)
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.blue,
                      size: 30,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleItemTap(BuildContext context, MenuItems item) async {
    if (item.ussdCode != null) {
      // Mostrar diálogo de confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ejecutar ${item.title}'),
          content: Text('¿Deseas ejecutar el código ${item.ussdCode}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ejecutar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final Uri ussdUri = Uri(scheme: 'tel', path: item.ussdCode!);
        if (await canLaunchUrl(ussdUri)) {
          await launchUrl(ussdUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo ejecutar el código USSD')),
          );
        }
      }
    } else if (item.title == "Recargar") {
      _showRechargeDialog(context);
    } else if (item.title == "Transferir saldo") {
      _showTransferDialog(context);
    } else if (item.title == "Llamada normal") {
      _showDialerDialog(context);
    }
  }

  // Métodos para mostrar diálogos (similares a los de HomePage)
  void _showRechargeDialog(BuildContext context) {
    // Implementación similar a la de HomePage
  }

  void _showTransferDialog(BuildContext context) {
    // Implementación similar a la de HomePage
  }

  void _showDialerDialog(BuildContext context) {
    // Implementación similar a la de HomePage
  }
}
