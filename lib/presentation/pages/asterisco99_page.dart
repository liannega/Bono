import 'package:bono/models/history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:url_launcher/url_launcher.dart';

class Asterisco99Page extends StatefulWidget {
  const Asterisco99Page({super.key});

  @override
  State<Asterisco99Page> createState() => _Asterisco99PageState();
}

class _Asterisco99PageState extends State<Asterisco99Page> {
  final TextEditingController _phoneController = TextEditingController();
  bool _hasError = false;
  bool _isExecutingCall = false;

  // Canal para acceder a los contactos
  static const platform = MethodChannel('com.example.bono/contacts');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Color _getBorderColor(
      TextEditingController controller, bool hasError, int maxLength) {
    if (hasError) {
      return Colors.red;
    } else if (controller.text.length == maxLength) {
      return Colors.blue;
    } else {
      return Colors.red.withOpacity(0.5);
    }
  }

  // Método para realizar la llamada con *99
  Future<void> _makeCall() async {
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isExecutingCall = true;
      _hasError = false;
    });

    try {
      if (phone.startsWith('+53')) {
        phone = phone.substring(3);
      }

      phone = phone.replaceAll(RegExp(r'[^\d]'), '');

      if (phone.length > 8) {
        phone = phone.substring(phone.length - 8);
      }

      final callNumber = "*99$phone";

      final Uri callUri = Uri(scheme: 'tel', path: callNumber);

      // Realizar la llamada
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);

        final callItem = MenuItems(
          title: "Asterisco 99",
          subtitle: "Llamada con pago revertido a: $phone",
          icon: Icons.call,
          color: Colors.blue,
          ussdCode: "*99$phone#",
        );

        final history = await HistoryService.getHistory();
        final existingItem =
            history.where((item) => item.title == "Asterisco 99").toList();

        if (existingItem.isNotEmpty) {
          final updatedItem = HistoryItem(
            title: "Asterisco 99",
            subtitle: "Llamada con pago revertido a: $phone",
            code: "*99$phone#",
            timestamp: DateTime.now(),
            icon: Icons.call,
            color: Colors.blue,
          );
          await HistoryService.updateHistoryItem(
              existingItem.first, updatedItem);
        } else {
          await HistoryService.addToHistory(callItem, "*99$phone#");
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw 'No se pudo iniciar la llamada';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al realizar la llamada: ${e.toString()}',
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
          _isExecutingCall = false;
        });
      }
    }
  }

  // Método para seleccionar contacto usando MethodChannel
  Future<void> _selectContact() async {
    try {
      // Verificar permiso de contactos
      final hasPermission =
          await platform.invokeMethod('hasContactsPermission');
      if (!hasPermission) {
        await platform.invokeMethod('requestContactsPermission');
      }

      final String phoneNumber = await platform.invokeMethod('pickContact');

      if (phoneNumber.isNotEmpty) {
        String cleanNumber = phoneNumber;
        if (cleanNumber.startsWith('+53')) {
          cleanNumber = cleanNumber.substring(3);
        }

        cleanNumber = cleanNumber.replaceAll(RegExp(r'[^\d]'), '');

        if (cleanNumber.length > 8) {
          cleanNumber = cleanNumber.substring(cleanNumber.length - 8);
        }

        setState(() {
          _phoneController.text = cleanNumber;
          _hasError = false;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al acceder a los contactos: $e',
            style: GoogleFonts.montserrat(
              letterSpacing: -0.3,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Asterisco 99',
          style: GoogleFonts.montserrat(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Añadimos el Hero para el icono grande con tamaño ajustado
            const SizedBox(height: 40),
            const Hero(
              tag: 'menu_icon_Asterisco_99',
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 40),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getBorderColor(_phoneController, _hasError, 8),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.call,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  // Campo de texto
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      style: GoogleFonts.montserrat(
                        color: textColor,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'TELEFONO',
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(8),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (_hasError && value.isNotEmpty) {
                            _hasError = false;
                          }
                        });
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: _selectContact,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.contact_phone,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mensaje de error
                  Text(
                    _hasError ? 'Este campo no debe estar vacío' : '',
                    style: GoogleFonts.montserrat(
                      color: Colors.red,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // Contador de caracteres
                  Text(
                    '${_phoneController.text.length}/8',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isExecutingCall ? null : _makeCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isExecutingCall
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.call, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
