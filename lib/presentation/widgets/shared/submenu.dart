import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/history_service.dart';
import 'package:bono/home_screen.dart';
import 'package:bono/presentation/widgets/shared/items.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmenuPage extends StatefulWidget {
  final String title;
  final List<MenuItems> items;
  final String? parentHeroTag;
  final IconData? parentIcon;
  final Color? parentColor;
  final String? parentTitle; // Añadido para rastrear el título del padre

  const SubmenuPage({
    super.key,
    required this.title,
    required this.items,
    this.parentHeroTag,
    this.parentIcon,
    this.parentColor,
    this.parentTitle,
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

  // Obtener el icono grande para mostrar en la parte superior según el título
  Widget _getHeaderIcon() {
    double iconSize = 80.0;
    Color iconColor = Colors.white;

    switch (widget.title) {
      case "Planes Combinados":
        return Icon(
          Icons.sync,
          color: iconColor,
          size: iconSize,
        );
      case "Planes de Datos":
        return Icon(
          Icons.data_usage,
          color: iconColor,
          size: iconSize,
        );
      case "Planes de Voz":
        return Icon(
          Icons.phone_in_talk,
          color: iconColor,
          size: iconSize,
        );
      case "Planes de SMS":
        return Icon(
          Icons.sms,
          color: iconColor,
          size: iconSize,
        );
      case "Plan amigos":
        return Icon(
          Icons.people,
          color: iconColor,
          size: iconSize,
        );
      case "Gestionar Planes":
        return Icon(
          Icons.shopping_cart,
          color: iconColor,
          size: iconSize,
        );
      case "Tarifa por consumo":
        return Icon(
          Icons.trending_up,
          color: iconColor,
          size: iconSize,
        );
      case "SOLO Líneas USIM con LTE (nuevas)":
        return Icon(
          Icons.data_usage,
          color: iconColor,
          size: iconSize,
        );
      default:
        // Si hay un icono padre, mostrar ese
        if (widget.parentIcon != null) {
          return Icon(
            widget.parentIcon!,
            color: iconColor,
            size: iconSize,
          );
        }
        // Icono por defecto
        return Icon(
          Icons.folder_open,
          color: iconColor,
          size: iconSize,
        );
    }
  }

  // Determinar si un elemento debe mostrar una flecha a la derecha
  bool _shouldShowChevron(MenuItems item) {
    // Mostrar flecha para elementos con submenú
    if (item.hasSubmenu) return true;

    // Mostrar flecha para elementos específicos que tienen navegación adicional
    if (widget.title == "Planes de Datos") {
      return item.title == "Tarifa por consumo" ||
          item.title == "SOLO Líneas USIM con LTE (nuevas)";
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isManagePlans = widget.title == "Gestionar Planes";
    final isPlanSubmenu = widget.title.startsWith("Plan") ||
        widget.title == "Tarifa por consumo" ||
        widget.title == "SOLO Líneas USIM con LTE (nuevas)";

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
          if (widget.parentHeroTag != null && !isPlanSubmenu)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Hero(
                tag: widget.parentHeroTag!,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: widget.parentColor ?? Colors.blue,
                  child: Icon(
                    widget.parentIcon ?? Icons.folder_open,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),

          // Icono grande para los submenús de planes
          if (isPlanSubmenu)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _getHeaderIcon(),
            ),

          // Lista de elementos
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];

                // Crear un tag único para cada elemento del submenú
                // Incluir el título del padre para asegurar unicidad
                final heroTag = 'submenu_icon_${widget.title}_${item.title}'
                    .replaceAll(" ", "_");

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: InkWell(
                      onTap: () => _handleItemTap(context, item, heroTag),
                      borderRadius: BorderRadius.circular(12),
                      splashColor: item.color.withOpacity(0.3),
                      highlightColor: item.color.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 8.0),
                        child: Row(
                          children: [
                            // Envolver el CircleAvatar en un Hero para la animación
                            Hero(
                              tag: heroTag,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors
                                    .blue, // Todos los círculos son azules en los submenús de planes
                                child: Icon(
                                  item.icon,
                                  color: Colors.white,
                                  size: 30,
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
                            // Flecha a la derecha para elementos con submenú o navegación adicional
                            if (_shouldShowChevron(item))
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
            parentIcon: item.icon,
            parentColor: item.color,
            parentTitle:
                widget.title, // Pasar el título actual como título del padre
          ),
        ),
      );
    } else if (item.ussdCode != null) {
      // Ejecutar el código USSD directamente sin confirmación para todos los submenús de planes
      if (widget.title.startsWith("Plan") ||
          widget.title == "Gestionar Planes" ||
          widget.title == "Tarifa por consumo" ||
          widget.title == "SOLO Líneas USIM con LTE (nuevas)" ||
          (widget.title == "Gestionar Saldo" &&
              item.title == "Consultar Saldo")) {
        await _executeUssdCodeDirectly(item.ussdCode!, item.title, item);
      } else {
        // Para otros submenús, mostrar confirmación
        await _executeUssdCode(item.ussdCode!, item.title, item);
      }
    } else if (item.title == "Recargar") {
      _showRechargeDialog(context);
    } else if (item.title == "Transferir saldo") {
      _showTransferDialog(context);
    } else if (item.title == "Llamada normal") {
      _showDialerDialog(context);
    }
  }

  // Método para ejecutar códigos USSD directamente sin confirmación
  Future<void> _executeUssdCodeDirectly(
      String code, String title, MenuItems item) async {
    if (_isExecutingUssd) return; // Evitar múltiples ejecuciones simultáneas

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
          // Agregar al historial si se ejecutó correctamente
          HistoryService.addToHistory(item, ussdCode);
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

  // Método centralizado para ejecutar códigos USSD con confirmación
  Future<void> _executeUssdCode(
      String code, String title, MenuItems item) async {
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

    // Ejecutar el código USSD directamente
    await _executeUssdCodeDirectly(code, title, item);
  }

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

                // Crear un elemento de menú temporal para el historial
                final rechargeItem = MenuItems(
                  title: "Recargar Saldo",
                  subtitle: "Código: $code",
                  icon: Icons.add_card,
                  color: Colors.green,
                  ussdCode: "*662*$code",
                );

                // Ejecutar el código de recarga
                await _executeUssdCodeDirectly(
                    "*662*$code", "Recargar Saldo", rechargeItem);
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

                // Crear un elemento de menú temporal para el historial
                final transferItem = MenuItems(
                  title: "Transferir Saldo",
                  subtitle: "A: $phone, Monto: $amount",
                  icon: Icons.send_to_mobile,
                  color: Colors.orange,
                  ussdCode: "*234*1*$phone*$amount",
                );

                // Ejecutar el código de transferencia
                await _executeUssdCodeDirectly(
                    "*234*1*$phone*$amount", "Transferir Saldo", transferItem);
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

                // Crear un elemento de menú temporal para el historial
                final callItem = MenuItems(
                  title: "Llamada",
                  subtitle: "Número: $phone",
                  icon: Icons.call,
                  color: Colors.green,
                  ussdCode: phone,
                );

                // Ejecutar la llamada
                await _executeUssdCodeDirectly(phone, "Llamada", callItem);
              }
            },
            child: const Text('Llamar'),
          ),
        ],
      ),
    );
  }
}
