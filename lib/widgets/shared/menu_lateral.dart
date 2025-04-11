import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const CustomDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF212121),
      child: Column(
        children: [
          // Header con logo y título
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón de tema en la esquina superior derecha
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: IconButton(
                      icon: Icon(
                        isDarkMode
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        onThemeChanged(!isDarkMode);
                      },
                    ),
                  ),
                ),
                // Logo circular
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/logo4.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Texto "BONO"
                Text(
                  'BONO',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 87, 86, 86)),
          // Único elemento de Ajustes
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: Text(
              'Ajustes',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: -0.3, // Letras más juntas
              ),
            ),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              context.go('/settings'); // Usar GoRouter para navegar
            },
          ),
        ],
      ),
    );
  }
}
