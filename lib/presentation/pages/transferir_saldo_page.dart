import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:bono/config/utils/ussd_service.dart';

class TransferirSaldoPage extends StatefulWidget {
  const TransferirSaldoPage({super.key});

  @override
  State<TransferirSaldoPage> createState() => _TransferirSaldoPageState();
}

class _TransferirSaldoPageState extends State<TransferirSaldoPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  bool _phoneHasError = false;
  bool _amountHasError = false;
  bool _claveHasError = false;
  bool _isExecutingCall = false;
  bool _obscureText = true; // Para controlar la visibilidad de la clave

  // Canal para USSD
  static const platform = MethodChannel('com.example.bono/ussd');
  // Canal para contactos
  static const contactsChannel = MethodChannel('com.example.bono/contacts');

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  // Método para seleccionar contacto
  Future<void> _selectContact() async {
    try {
      // Verificar permiso de contactos
      final hasPermission =
          await contactsChannel.invokeMethod('hasContactsPermission');
      if (!hasPermission) {
        await contactsChannel.invokeMethod('requestContactsPermission');
      }

      // Abrir directamente el selector de contactos nativo
      final String phoneNumber =
          await contactsChannel.invokeMethod('pickContact');

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
          _phoneHasError = false;
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

  // Método para realizar la transferencia
  Future<void> _makeTransfer() async {
    // Validar campos
    setState(() {
      _phoneHasError = _phoneController.text.isEmpty;
      _amountHasError = _amountController.text.isEmpty;
      _claveHasError = _claveController.text.isEmpty;
    });

    // Si hay algún error, no continuar
    if (_phoneHasError || _amountHasError || _claveHasError) {
      return;
    }

    final phone = _phoneController.text.trim();
    final amount = _amountController.text.trim();
    final clave = _claveController.text.trim();

    // Mostrar diálogo de confirmación con resumen de la transferencia
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: Text(
          'Confirmar transferencia',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vas a transferir:',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: -0.3,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Número: $phone',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cantidad: $amount pesos',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              'Cuando se ejecute el código USSD, sigue las instrucciones en pantalla para completar la transferencia.',
              style: GoogleFonts.montserrat(
                color: Colors.grey,
                fontSize: 12,
                letterSpacing: -0.3,
                height: 1.3,
              ),
            ),
          ],
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
              'Transferir',
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

    if (confirm != true) return;

    setState(() {
      _isExecutingCall = true;
    });

    try {
      // Formatear el código USSD para transferencia
      final ussdCode = "*234*1*$phone*$amount*$clave";

      // Ejecutar el código USSD
      final success = await UssdService.executeUssd(ussdCode);

      if (success && mounted) {
        // Crear un elemento de menú temporal para el historial
        const transferItem = MenuItems(
          title: "Transferir Saldo",
          subtitle: "", // No incluir detalles en el subtítulo
          icon: Icons.send_to_mobile,
          color: Colors.orange, // Cambiar a naranja como en la imagen
          ussdCode:
              "*234", // Solo mostrar el código base sin información sensible
        );

        // Agregar al historial
        await HistoryService.addToHistory(transferItem, "*234");

        // Volver a la pantalla anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al realizar la transferencia: $e',
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

  // Determinar si un campo debe tener borde azul
  Color _getBorderColor(
      TextEditingController controller, bool hasError, int maxLength,
      {bool isAmount = false}) {
    if (hasError) {
      return Colors.red;
    } else if (isAmount && controller.text.isNotEmpty) {
      // Para el campo de cantidad, se pone azul cuando tiene al menos 1 dígito
      return Colors.blue;
    } else if (!isAmount && controller.text.length == maxLength) {
      // Para otros campos, se pone azul cuando tiene la longitud máxima
      return Colors.blue;
    } else {
      return Colors.red.withOpacity(0.5);
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
          'Transferir Saldo',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Icono de transferencia con Hero (solo flecha en círculo azul)
              const SizedBox(height: 40),
              const Hero(
                tag: 'menu_icon_Transferir_saldo',
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Campo de teléfono
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(_phoneController, _phoneHasError, 8),
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
                        Icons.phone,
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
                          setState(() {
                            _phoneHasError = false;
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
              // Mensaje de error y contador para teléfono
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mensaje de error
                    Text(
                      _phoneHasError ? 'Este campo no debe estar vacío' : '',
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

              const SizedBox(height: 10),

              // Campo de cantidad
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(
                        _amountController, _amountHasError, 4,
                        isAmount: true),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Ícono de dinero a la izquierda
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    // Campo de texto
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                        decoration: InputDecoration(
                          hintText: 'CANTIDAD',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _amountHasError = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Mensaje de error y contador para cantidad
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mensaje de error
                    Text(
                      _amountHasError ? 'Este campo no debe estar vacío' : '',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                    // Contador de caracteres
                    Text(
                      '${_amountController.text.length}/4',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Título CLAVE
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CLAVE',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 1,
                      width: 40,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

              // Campo de clave
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getBorderColor(_claveController, _claveHasError, 4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Ícono de llave a la izquierda
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.key,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    // Campo de texto
                    Expanded(
                      child: TextField(
                        controller: _claveController,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                        decoration: InputDecoration(
                          hintText: '',
                          hintStyle: GoogleFonts.montserrat(
                            color: Colors.grey,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: _obscureText,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          setState(() {
                            _claveHasError = false;
                          });
                        },
                      ),
                    ),
                    // Icono para mostrar/ocultar clave
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Mensaje de error y contador para clave
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mensaje de error
                    Text(
                      _claveHasError ? 'Este campo no debe estar vacío' : '',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                    // Contador de caracteres
                    Text(
                      '${_claveController.text.length}/4',
                      style: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de transferencia
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isExecutingCall ? null : _makeTransfer,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
