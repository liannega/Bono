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

  // Lista de números útiles
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

  // Método para realizar llamadas directas
  Future<void> _makeDirectCall(MenuItems item) async {
    if (_isExecutingCall) return;

    setState(() {
      _isExecutingCall = true;
    });

    try {
      // Obtener el número de teléfono
      String phoneNumber = item.ussdCode!;

      // Ejecutar la llamada directamente usando el método nativo
      await const MethodChannel('com.example.bono/ussd')
          .invokeMethod('makeDirectCall', {
        'phoneNumber': phoneNumber,
      });

      // Agregar al historial
      await HistoryService.addToHistory(item, phoneNumber);
    } catch (e) {
      if (mounted) {
        // Mostrar un mensaje de error pero no un diálogo
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
    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      appBar: AppBar(
        backgroundColor: const Color(0xFF333333),
        elevation: 0,
        title: Text(
          'Números útiles',
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
      body: Column(
        children: [
          // Añadimos el Hero para el icono grande con tamaño ajustado
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

          // Lista de números útiles
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
