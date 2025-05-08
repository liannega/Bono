import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/services/dialog_service.dart';
import 'package:bono/services/ussd_service.dart';
import 'package:bono/widgets/common/item_general.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _checkPermission() async {
    final hasPermission = await UssdService.hasCallPermission();
    if (!hasPermission) {
      await UssdService.requestCallPermission();
    }
  }

  void _setExecuting(bool isExecuting) {
    setState(() {
      _isExecutingUssd = isExecuting;
    });
  }

  void _setStatusMessage(String? message) {}

  Widget _getHeaderIcon() {
    double iconSize = 30.0;
    Color iconColor = Colors.white;
    Color backgroundColor = Colors.blue;

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

    IconData iconData =
        titleIcons[widget.title] ?? widget.parentIcon ?? Icons.folder_open;

    final heroTag = 'menu_icon_${widget.title.replaceAll(" ", "_")}';

    return Hero(
      tag: heroTag,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(
          iconData,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

  bool _shouldShowChevron(MenuItems item) {
    if (item.hasSubmenu) return true;

    if (widget.title == "Planes de Datos") {
      return item.title == "Tarifa por consumo" ||
          item.title == "SOLO Líneas USIM con LTE (nuevas)";
    }

    return false;
  }

  void _handleItemTap(
      BuildContext context, MenuItems item, String heroTag) async {
    if (widget.title == "Gestionar Llamadas") {
      _handleCallManagementItem(context, item, heroTag);
      return;
    }

    if (item.hasSubmenu && item.submenuItems != null) {
      final consistentHeroTag = 'menu_icon_${item.title.replaceAll(" ", "_")}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubmenuPage(
            title: item.title,
            items: item.submenuItems!,
            parentHeroTag: consistentHeroTag,
            parentIcon: item.icon,
            parentColor: item.color,
            parentTitle: widget.title,
          ),
        ),
      );
      return;
    }

    if (item.ussdCode != null) {
      await _handleUssdItem(context, item);
      return;
    }

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

  void _handleCallManagementItem(
      BuildContext context, MenuItems item, String heroTag) {
    switch (item.title) {
      case "Asterisco 99":
        context.go('/asterisco99');
        break;
      case "Mi número oculto":
        context.go('/numero-oculto');
        break;
      case "Números útiles":
        context.go('/numeros-utiles');
        break;
    }
  }

 

  Future<void> _handleUssdItem(BuildContext context, MenuItems item) async {
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
      final rechargeItem = MenuItems(
        title: "Recargar Saldo",
        subtitle: "Código: $code",
        icon: Icons.add_card,
        color: Colors.green,
        ussdCode: "*662*$code",
      );

      await UssdExecutorService.executeUssdCodeDirectly(
        code: "*662*$code",
        item: rechargeItem,
        setExecuting: _setExecuting,
        setStatusMessage: _setStatusMessage,
      );
    }
  }

  void _showTransferDialog(BuildContext context) {
    context.go('/transferir-saldo');
  }

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

    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.colorScheme.onSurface;
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: GoogleFonts.montserrat(
            color: isLightMode ? Colors.blue : textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isLightMode ? Colors.blue : textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.parentHeroTag != null && !isPlanSubmenu
                ? Hero(
                    tag: widget.parentHeroTag!,
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: widget.parentColor ?? Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: isLightMode
                            ? [
                                BoxShadow(
                                  color: (widget.parentColor ?? Colors.blue)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];

                final heroTag = 'submenu_icon_${widget.title}_${item.title}'
                    .replaceAll(" ", "_");

                return ItemGeneral(
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  color: Colors.blue,
                  showChevron: _shouldShowChevron(item),
                  heroTag: heroTag,
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
