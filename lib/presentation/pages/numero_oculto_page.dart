import 'package:bono/models/history_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:url_launcher/url_launcher.dart';

class NumeroOcultoPage extends StatefulWidget {
  const NumeroOcultoPage({super.key});

  @override
  State<NumeroOcultoPage> createState() => _NumeroOcultoPageState();
}

class _NumeroOcultoPageState extends State<NumeroOcultoPage> {
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

  // Determinar si un campo debe tener borde azul
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

  // Método para realizar la llamada con número oculto
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
      // Extraer solo los 8 dígitos del número
      // Si el número comienza con +53, eliminarlo
      if (phone.startsWith('+53')) {
        phone = phone.substring(3);
      }

      // Eliminar cualquier carácter que no sea dígito
      phone = phone.replaceAll(RegExp(r'[^\d]'), '');

      // Tomar solo los últimos 8 dígitos si el número es más largo
      if (phone.length > 8) {
        phone = phone.substring(phone.length - 8);
      }

      // Formatear el número con #31# delante para la llamada con número oculto
      final callNumber = "#31#$phone";

      // Crear la URI para la llamada
      final Uri callUri = Uri(scheme: 'tel', path: callNumber);

      // Realizar la llamada
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);

        // Crear un elemento de menú temporal para el historial
        final callItem = MenuItems(
          title: "Mi número oculto",
          subtitle: "Llamada a: $phone",
          icon: Icons.call,
          color: Colors.blue,
          ussdCode: "#31#$phone",
        );

        // Primero verificar si ya existe una entrada para Mi número oculto
        final history = await HistoryService.getHistory();
        final existingItem =
            history.where((item) => item.title == "Mi número oculto").toList();

        if (existingItem.isNotEmpty) {
          // Si existe, actualizar la entrada existente
          final updatedItem = HistoryItem(
            title: "Mi número oculto",
            subtitle: "Llamada a: $phone",
            code: "#31#$phone",
            timestamp: DateTime.now(),
            icon: Icons.call,
            color: Colors.blue,
          );
          await HistoryService.updateHistoryItem(
              existingItem.first, updatedItem);
        } else {
          // Si no existe, agregar una nueva entrada
          await HistoryService.addToHistory(callItem, "#31#$phone");
        }

        // Volver a la pantalla anterior después de iniciar la llamada
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

      // Abrir directamente el selector de contactos nativo
      final String phoneNumber = await platform.invokeMethod('pickContact');

      if (phoneNumber.isNotEmpty) {
        // Eliminar el prefijo +53 si existe
        String cleanNumber = phoneNumber;
        if (cleanNumber.startsWith('+53')) {
          cleanNumber = cleanNumber.substring(3);
        }

        // Eliminar cualquier carácter que no sea dígito
        cleanNumber = cleanNumber.replaceAll(RegExp(r'[^\d]'), '');

        // Tomar solo los últimos 8 dígitos si el número es más largo
        if (cleanNumber.length > 8) {
          cleanNumber = cleanNumber.substring(cleanNumber.length - 8);
        }

        setState(() {
          _phoneController.text = cleanNumber;
          _hasError = false;
        });
      }
    } catch (e) {
      // Mostrar un mensaje de error pero no un diálogo
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
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        elevation: 0,
        title: Text(
          'Mi número oculto',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              tag: 'menu_icon_Mi_número_oculto',
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
            // Campo de entrada de teléfono
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
                  // Ícono de teléfono a la izquierda
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
                        color: Colors.white,
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
                        // Forzar actualización del estado para que se actualice el color del borde
                        setState(() {
                          if (_hasError && value.isNotEmpty) {
                            _hasError = false;
                          }
                        });
                      },
                    ),
                  ),
                  // Ícono de contactos a la derecha
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
            // Mensaje de error y contador
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
            // Botón de llamada
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
