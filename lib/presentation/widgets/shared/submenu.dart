import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/home_screen.dart';
import 'package:bono/presentation/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmenuPage extends StatefulWidget {
  final String title;
  final List<MenuItems> items;
  final String? parentHeroTag;
  final IconData? parentIcon; // Agregar el icono del elemento padre
  final Color? parentColor; // Agregar el color del elemento padre

  const SubmenuPage({
    super.key,
    required this.title,
    required this.items,
    this.parentHeroTag,
    this.parentIcon, // Icono del elemento padre
    this.parentColor, // Color del elemento padre
  });

  @override
  State<SubmenuPage> createState() => _SubmenuPageState();
}

class _SubmenuPageState extends State<SubmenuPage> {
  String? _statusMessage;
  bool _isExecutingUssd = false;

  @override
  void initState() {
    super.initState();
    // Verificar permiso al iniciar
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await UssdService.hasCallPermission();
    if (!hasPermission) {
      // Solicitar permiso si no lo tiene
      await UssdService.requestCallPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.title,
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
      body: Column(
        children: [
          // Mensaje de estado
          if (_statusMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          // Icono del elemento padre con animación Hero
          if (widget.parentHeroTag != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Hero(
                tag: widget.parentHeroTag!,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: backgroundColor,
                  child: Icon(
                    widget.parentIcon ??
                        Icons.folder_open, // Usar el icono del elemento padre
                    color: Colors.white,
                    size: 65,
                  ),
                ),
              ),
            ),

          // Lista de elementos
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                // Crear un tag único para cada elemento del submenú
                final heroTag = 'submenu_icon_${widget.title}_${item.title}'
                    .replaceAll(" ", "_");

                // ... (código existente)

// En el método build, dentro del ListView.builder, reemplaza el GestureDetector con InkWell:
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => _handleItemTap(context, item, heroTag),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: item.color.withOpacity(0.3),
                      highlightColor: item.color.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 8.0),
                        child: Row(
                          children: [
                            // Envolver el CircleAvatar en un Hero para la animación
                            Hero(
                              tag: heroTag,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: item.color,
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Método principal para manejar los toques en los elementos
  void _handleItemTap(
      BuildContext context, MenuItems item, String heroTag) async {
    if (item.hasSubmenu && item.submenuItems != null) {
      // Navegar al submenú con el heroTag y el icono del elemento
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmenuPage(
            title: item.title,
            items: item.submenuItems!,
            parentHeroTag: heroTag,
            parentIcon: item.icon, // Pasar el icono del elemento
            parentColor: item.color, // Pasar el color del elemento
          ),
        ),
      );
    } else if (item.ussdCode != null) {
      // Ejecutar código USSD usando el servicio nativo
      await _executeUssdCode(item.ussdCode!, item.title);
    } else if (item.title == "Recargar") {
      _showRechargeDialog(context);
    } else if (item.title == "Transferir saldo") {
      _showTransferDialog(context);
    } else if (item.title == "Llamada normal") {
      _showDialerDialog(context);
    }
  }

  // Método centralizado para ejecutar códigos USSD
  Future<void> _executeUssdCode(String code, String title) async {
    if (_isExecutingUssd) return; // Evitar múltiples ejecuciones simultáneas

    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ejecutar $title'),
        content: Text('¿Deseas ejecutar el código $code?'),
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

    if (confirm != true) return;

    // Evitar múltiples ejecuciones simultáneas
    setState(() {
      _isExecutingUssd = true;
      _statusMessage = "Ejecutando código USSD...";
    });

    try {
      // Asegurarse de que el código tenga el formato correcto
      var ussdCode = code.trim();
      if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
        ussdCode = "*$ussdCode";
      }

      if (!ussdCode.endsWith("#")) {
        ussdCode = "$ussdCode#";
      }

      // Ejecutar el código USSD usando el servicio nativo
      final success = await UssdService.executeUssd(ussdCode);

      if (!mounted) return; // Verificar si el widget está montado

      setState(() {
        if (success) {
          _statusMessage = "Código USSD ejecutado correctamente";
        } else {
          _statusMessage = "Error al ejecutar el código USSD";
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Error: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExecutingUssd = false;
        });

        // Limpiar el mensaje después de 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _statusMessage = null;
            });
          }
        });
      }
    }
  }

  // Los métodos para mostrar diálogos permanecen igual

  // Diálogo para recargar
  void _showRechargeDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recargar Saldo'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: 'Código de recarga',
            hintText: 'Ingresa el código de recarga',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                // Ejecutar el código de recarga
                await _executeUssdCode("*662*$code", "Recargar Saldo");
              }
            },
            child: const Text('Recargar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para transferir saldo
  void _showTransferDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transferir Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Número de teléfono',
                hintText: 'Ingresa el número de teléfono',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Monto a transferir',
                hintText: 'Ingresa el monto',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              final amount = amountController.text.trim();
              if (phone.isNotEmpty && amount.isNotEmpty) {
                Navigator.pop(context);
                // Ejecutar el código de transferencia
                await _executeUssdCode(
                    "*234*1*$phone*$amount", "Transferir Saldo");
              }
            },
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
  }

  // Diálogo para llamada normal
  void _showDialerDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realizar Llamada'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Número de teléfono',
            hintText: 'Ingresa el número de teléfono',
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isNotEmpty) {
                Navigator.pop(context);
                // Ejecutar la llamada
                await _executeUssdCode(phone, "Llamada");
              }
            },
            child: const Text('Llamar'),
          ),
        ],
      ),
    );
  }
}
