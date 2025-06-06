import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:bono/widgets/common/item_general.dart';

class NumerosUtilesPage extends StatefulWidget {
  const NumerosUtilesPage({super.key});

  @override
  State<NumerosUtilesPage> createState() => _NumerosUtilesPageState();
}

class _NumerosUtilesPageState extends State<NumerosUtilesPage> {
  bool _isExecutingCall = false;

  final List<MenuItems> _numerosUtiles = const [
    MenuItems(
      title: "*2266 - Atención al cliente",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "*2266",
    ),
    MenuItems(
      title: "103 - Línea Antidrogas",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "103",
    ),
    MenuItems(
      title: "104 - Ambulancias",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "104",
    ),
    MenuItems(
      title: "105 - Bomberos",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "105",
    ),
    MenuItems(
      title: "106 - Policía",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "106",
    ),
    MenuItems(
      title: "107 - Salvamento Marítimo",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "107",
    ),
    MenuItems(
      title: "118 - Cubacel Info",
      icon: Icons.call,
      color: Colors.blue,
      ussdCode: "118",
    ),
  ];

  Future<void> _makeDirectCall(MenuItems item) async {
    if (_isExecutingCall) return;

    setState(() {
      _isExecutingCall = true;
    });

    try {
      String phoneNumber = item.ussdCode!;

      await const MethodChannel('com.example.bono/ussd')
          .invokeMethod('makeDirectCall', {
        'phoneNumber': phoneNumber,
      });

      await HistoryService.addToHistory(item, phoneNumber);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al realizar la llamada: $e',
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
          'Números útiles',
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Hero(
            tag: 'menu_icon_Números_útiles',
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
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _numerosUtiles.length,
              itemBuilder: (context, index) {
                final item = _numerosUtiles[index];
                return ItemGeneral(
                  icon: item.icon,
                  title: item.title,
                  color: Colors.blue,
                  onTap: () => _makeDirectCall(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
