import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isFloatingWidgetEnabled = false;
  bool isWifiDisconnectEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ajustes',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Switches
                  _buildSwitchTile(
                    'Activar widget flotante',
                    isFloatingWidgetEnabled,
                    (value) {
                      setState(() {
                        isFloatingWidgetEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Apagar wifi al desconectar',
                    isWifiDisconnectEnabled,
                    (value) {
                      setState(() {
                        isWifiDisconnectEnabled = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  // Botones
                  _buildButton(
                    'Términos de uso',
                    Icons.check_circle,
                    onTap: () {
                      // Implementar acción
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Habla con nosotros',
                    Icons.telegram,
                    onTap: () {
                      // Implementar acción
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    'Actualizar códigos USSD',
                    Icons.download,
                    onTap: () {
                      // Implementar acción
                    },
                  ),
                ],
              ),
            ),
          ),
          // Versión en la parte inferior
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Text(
              'BONO v1.0',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
          activeTrackColor: Colors.blue.withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _buildButton(String title, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
