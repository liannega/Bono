import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Servicio para manejar diálogos comunes en la aplicación
class DialogService {
  /// Muestra un diálogo de confirmación genérico
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Cancelar',
    String confirmText = 'Aceptar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        content: Text(
          content,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 14,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
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
  }

  /// Muestra un diálogo con un campo de texto
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    required String labelText,
    String hintText = '',
    String cancelText = 'Cancelar',
    String confirmText = 'Aceptar',
    TextInputType keyboardType = TextInputType.text,
  }) {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            labelStyle: GoogleFonts.montserrat(
              color: Colors.blue,
              letterSpacing: -0.3,
            ),
            hintStyle: GoogleFonts.montserrat(
              color: Colors.grey,
              letterSpacing: -0.3,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: GoogleFonts.montserrat(
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          keyboardType: keyboardType,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(
              cancelText,
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                letterSpacing: -0.3,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              confirmText,
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
  }
}

