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
  bool _obscureText = true;

  // static const platform = MethodChannel('com.example.bono/ussd');

  static const contactsChannel = MethodChannel('com.example.bono/contacts');

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _selectContact() async {
    try {
      final hasPermission =
          await contactsChannel.invokeMethod('hasContactsPermission');
      if (!hasPermission) {
        await contactsChannel.invokeMethod('requestContactsPermission');
      }

      final String phoneNumber =
          await contactsChannel.invokeMethod('pickContact');

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
          _phoneHasError = false;
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

  Future<void> _makeTransfer() async {
    setState(() {
      _phoneHasError = _phoneController.text.isEmpty;
      _amountHasError = _amountController.text.isEmpty;
      _claveHasError = _claveController.text.isEmpty;
    });

    if (_phoneHasError || _amountHasError || _claveHasError) {
      return;
    }

    final phone = _phoneController.text.trim();
    final amount = _amountController.text.trim();
    final clave = _claveController.text.trim();

    final theme = Theme.of(context);
    final backgroundColor = theme.dialogBackgroundColor;
    final textColor = theme.colorScheme.onSurface;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(
          'Confirmar transferencia',
          style: GoogleFonts.montserrat(
            color: textColor,
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
                color: textColor,
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
                    color: textColor,
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
                    color: textColor,
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
      final ussdCode = "*234*1*$phone*$amount*$clave";

      final success = await UssdService.executeUssd(ussdCode);

      if (success && mounted) {
        const transferItem = MenuItems(
          title: "Transferir Saldo",
          subtitle: "",
          icon: Icons.send_to_mobile,
          color: Colors.orange,
          ussdCode: "*234",
        );

        await HistoryService.addToHistory(transferItem, "*234");

        // ignore: use_build_context_synchronously
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

  Color _getBorderColor(
      TextEditingController controller, bool hasError, int maxLength,
      {bool isAmount = false}) {
    if (hasError) {
      return Colors.red;
    } else if (isAmount && controller.text.isNotEmpty) {
      return Colors.blue;
    } else if (!isAmount && controller.text.length == maxLength) {
      return Colors.blue;
    } else {
      return Colors.red.withOpacity(0.5);
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
          'Transferir Saldo',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
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
                            _phoneHasError = false;
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
                    Text(
                      _phoneHasError ? 'Este campo no debe estar vacío' : '',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        style: GoogleFonts.montserrat(
                          color: textColor,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _amountHasError ? 'Este campo no debe estar vacío' : '',
                      style: GoogleFonts.montserrat(
                        color: Colors.red,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    ),
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
                        color: textColor,
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.key,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _claveController,
                        style: GoogleFonts.montserrat(
                          color: textColor,
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
