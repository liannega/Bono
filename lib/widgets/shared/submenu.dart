import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/presentation/pages/asterisco99_page.dart';
import 'package:bono/presentation/pages/home_page.dart';
import 'package:bono/presentation/pages/numero_oculto_page.dart';
import 'package:bono/presentation/pages/numeros_utiles_page.dart';
import 'package:bono/presentation/pages/transferir_saldo_page.dart';
import 'package:bono/services/dialog_service.dart';
import 'package:bono/services/ussd_service.dart';
import 'package:bono/widgets/menu/menu_item.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubmenuPage extends StatefulWidget {
  final String title;
  final List<MenuItems> items;
  final String? parentHeroTag;
  final IconData? parentIcon;
  final Color? parentColor;
  final String? parentTitle;

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
    _checkPermission();
  }

  // Verificar y solicitar permisos necesarios
  Future<void> _checkPermission() async {
    final hasPermission = await UssdService.hasCallPermission();
    if (!hasPermission) {
      await UssdService.requestCallPermission();
    }
  }

  // Actualizar el estado de ejecución USSD
  void _setExecuting(bool isExecuting) {
    setState(() {
      _isExecutingUssd = isExecuting;
    });
  }

  // Actualizar el mensaje de estado
  void _setStatusMessage(String? message) {
    // No hacer nada - mensajes de estado desactivados
  }

  // Obtener el icono grande para mostrar en la parte superior según el título
  Widget _getHeaderIcon() {
    double iconSize = 30.0;
    Color iconColor = Colors.white;
    Color backgroundColor = Colors.blue;

    // Mapa de títulos a iconos para simplificar la lógica
    final Map<String, IconData> titleIcons = {
      "Planes Combinados": Icons.sync,
      "Planes de Datos": Icons.data_usage,
      "Planes de Voz": Icons.phone_in_talk,
      "Planes de SMS": Icons.sms,
      "Plan amigos": Icons.people,
      "Gestionar Planes": Icons.shopping_cart,
      "Tarifa por consumo": Icons.trending_up,
      "SOLO Líneas USIM con LTE (nuevas)": Icons.data_usage,
      "Gestionar Llamadas": Icons.call,
    };

    // Buscar el icono en el mapa o usar el icono padre o uno por defecto
    IconData iconData =
        titleIcons[widget.title] ?? widget.parentIcon ?? Icons.folder_open;

    // Crear un CircleAvatar con Hero para la animación
    return Hero(
      tag: 'icon_hero_${widget.title}',
      child: CircleAvatar(
        radius: 35,
        backgroundColor: backgroundColor,
        child: Icon(
          iconData,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
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

  // Método principal para manejar los toques en los elementos
  void _handleItemTap(
      BuildContext context, MenuItems item, String heroTag) async {
    // Manejar casos especiales para Gestionar Llamadas
    if (widget.title == "Gestionar Llamadas") {
      _handleCallManagementItem(context, item, heroTag);
      return;
    }

    // Manejar elementos con submenú
    if (item.hasSubmenu && item.submenuItems != null) {
      _navigateToSubmenu(context, item, heroTag);
      return;
    }

    // Manejar elementos con código USSD
    if (item.ussdCode != null) {
      await _handleUssdItem(context, item);
      return;
    }

    // Manejar otros casos específicos
    switch (item.title) {
      case "Recargar":
        _showRechargeDialog(context);
        break;
      case "Transferir saldo":
        _showTransferDialog(context);
        break;
      case "Llamada normal":
        _showDialerDialog(context);
        break;
    }
  }

  // Manejar elementos específicos del menú Gestionar Llamadas
  void _handleCallManagementItem(
      BuildContext context, MenuItems item, String heroTag) {
    switch (item.title) {
      case "Asterisco 99":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Asterisco99Page(),
          ),
        );
        break;
      case "Mi número oculto":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NumeroOcultoPage(),
          ),
        );
        break;
      case "Números útiles":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NumerosUtilesPage(),
          ),
        );
        break;
    }
  }

  // Navegar a un submenú
  void _navigateToSubmenu(
      BuildContext context, MenuItems item, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmenuPage(
          title: item.title,
          items: item.submenuItems!,
          parentHeroTag: heroTag,
          parentIcon: item.icon,
          parentColor: item.color,
          parentTitle: widget.title,
        ),
      ),
    );
  }

  // Manejar elementos con código USSD
  Future<void> _handleUssdItem(BuildContext context, MenuItems item) async {
    // Determinar si se debe ejecutar directamente o mostrar confirmación
    bool executeDirectly = widget.title.startsWith("Plan") ||
        widget.title == "Gestionar Planes" ||
        widget.title == "Tarifa por consumo" ||
        widget.title == "SOLO Líneas USIM con LTE (nuevas)" ||
        (widget.title == "Gestionar Saldo" && item.title == "Consultar Saldo");

    if (executeDirectly) {
      await UssdExecutorService.executeUssdCodeDirectly(
        code: item.ussdCode!,
        item: item,
        setExecuting: _setExecuting,
        setStatusMessage: _setStatusMessage,
      );
    } else {
      await _executeUssdWithConfirmation(item);
    }
  }

  // Ejecutar código USSD con confirmación previa
  Future<void> _executeUssdWithConfirmation(MenuItems item) async {
    if (_isExecutingUssd) return;

    final confirm = await DialogService.showConfirmationDialog(
      context: context,
      title: 'Ejecutar ${item.title}',
      content: '¿Deseas ejecutar el código ${item.ussdCode}?',
      confirmText: 'Ejecutar',
    );

    if (confirm == true) {
      await UssdExecutorService.executeUssdCodeDirectly(
        code: item.ussdCode!,
        item: item,
        setExecuting: _setExecuting,
        setStatusMessage: _setStatusMessage,
      );
    }
  }

  // Diálogo para recargar
  void _showRechargeDialog(BuildContext context) async {
    final code = await DialogService.showInputDialog(
      context: context,
      title: 'Recargar Saldo',
      labelText: 'Código de recarga',
      hintText: 'Ingresa el código de recarga',
      confirmText: 'Recargar',
      keyboardType: TextInputType.number,
    );

    if (code != null && code.isNotEmpty && mounted) {
      // Crear un elemento de menú temporal para el historial
      final rechargeItem = MenuItems(
        title: "Recargar Saldo",
        subtitle: "Código: $code",
        icon: Icons.add_card,
        color: Colors.green,
        ussdCode: "*662*$code",
      );

      // Ejecutar el código de recarga
      await UssdExecutorService.executeUssdCodeDirectly(
        code: "*662*$code",
        item: rechargeItem,
        setExecuting: _setExecuting,
        setStatusMessage: _setStatusMessage,
      );
    }
  }

  // Diálogo para transferir saldo
  void _showTransferDialog(BuildContext context) {
    // Navegar a la página de transferencia de saldo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransferirSaldoPage(),
      ),
    );
  }

  // Diálogo para llamada normal
  void _showDialerDialog(BuildContext context) async {
    final phone = await DialogService.showInputDialog(
      context: context,
      title: 'Realizar Llamada',
      labelText: 'Número de teléfono',
      hintText: 'Ingresa el número de teléfono',
      confirmText: 'Llamar',
      keyboardType: TextInputType.phone,
    );

    if (phone != null && phone.isNotEmpty && mounted) {
      // Crear un elemento de menú temporal para el historial
      final callItem = MenuItems(
        title: "Llamada",
        subtitle: "Número: $phone",
        icon: Icons.call,
        color: Colors.green,
        ussdCode: phone,
      );

      // Ejecutar la llamada
      await UssdExecutorService.executeUssdCodeDirectly(
        code: phone,
        item: callItem,
        setExecuting: _setExecuting,
        setStatusMessage: _setStatusMessage,
      );
    }
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
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Mostrar solo un icono, ya sea el del padre o el generado por _getHeaderIcon
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: widget.parentHeroTag != null && !isPlanSubmenu
                ? Hero(
                    tag: widget.parentHeroTag!,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: widget.parentColor ?? Colors.blue,
                      child: Icon(
                        widget.parentIcon ?? Icons.folder_open,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  )
                : (isPlanSubmenu || widget.title == "Gestionar Llamadas")
                    ? _getHeaderIcon()
                    : const SizedBox.shrink(),
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

                return MenuItemCard(
                  item: item,
                  heroTag: heroTag,
                  showChevron: _shouldShowChevron(item),
                  onTap: () => _handleItemTap(context, item, heroTag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
