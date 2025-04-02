import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/presentation/pages/history_view.dart';
import 'package:bono/widgets/shared/menu_lateral.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:bono/widgets/shared/menu_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/presentation/pages/asterisco99_page.dart';

const backgroundColor = Color.fromARGB(255, 45, 44, 44);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isDarkMode = true;
  late PageController _pageController;
  late TabController _tabController;
  int _currentPage = 0;
  String? _statusMessage;
  bool _isExecutingUssd = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });

    // Verificar permiso al iniciar
    _checkPermission();

    // Inicializar el servicio de historial
    HistoryService.initialize();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await UssdService.hasCallPermission();
    if (!hasPermission) {
      // Solicitar permiso si no lo tiene
      await UssdService.requestCallPermission();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void handleMenuAction(MenuItems item) async {
    // Caso especial para Asterisco 99
    if (item.title == "Asterisco 99") {
      await _handleAsterisco99();
      return;
    }

    if (item.ussdCode != null && !_isExecutingUssd) {
      // Mostrar diálogo de confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF333333),
            title: Text(
              'Ejecutar ${item.title}',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: -0.5, // Letras más juntas
              ),
            ),
            content: Text(
              '¿Deseas ejecutar el código ${item.ussdCode}?',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: -0.3, // Letras más juntas
              ),
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
                  'Ejecutar',
                  style: GoogleFonts.montserrat(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.3,
                  ),
                ),
              )
            ]),
      );

      if (confirm != true) return;

      // Evitar múltiples ejecuciones simultáneas
      setState(() {
        _isExecutingUssd = true;
        _statusMessage = "Ejecutando código USSD...";
      });

      try {
        // Formatear el código USSD correctamente
        var ussdCode = item.ussdCode!.trim();
        if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
          ussdCode = "*$ussdCode";
        }

        if (!ussdCode.endsWith("#")) {
          ussdCode = "$ussdCode#";
        }

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
  }

  // Modificar el método _handleAsterisco99 para navegar a la página Asterisco99Page
  Future<void> _handleAsterisco99() async {
    // Navegar a la página Asterisco99Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Asterisco99Page(),
      ),
    );
  }

  // Método para actualizar el mensaje de estado desde la vista de historial
  void updateStatusMessage(String message) {
    // No hacer nada - mensajes de estado desactivados

    // Eliminamos la actualización del estado
    // setState(() {
    //   _statusMessage = message;
    // });

    // Eliminamos la limpieza del mensaje
    // Future.delayed(const Duration(seconds: 2), () {
    //   if (mounted) {
    //     setState(() {
    //       _statusMessage = null;
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'BONO',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.5, // Letras más juntas
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: CustomDrawer(
        isDarkMode: isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
      body: Column(
        children: [
          // Eliminamos el mensaje de estado
          // if (_statusMessage != null)
          //   Container(
          //     padding: const EdgeInsets.all(8),
          //     margin: const EdgeInsets.all(8),
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       color: Colors.blue.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Text(
          //       _statusMessage!,
          //       style: GoogleFonts.montserrat(
          //         color: Colors.white,
          //         letterSpacing: -0.3, // Letras más juntas
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),

          // Iconos de navegación superiores
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de teléfono
                InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: _currentPage == 0 ? Colors.blue : backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                // Icono de historial
                InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: _currentPage == 1 ? Colors.blue : backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PageView con las dos vistas
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                // Vista principal
                MenuList(
                  items: menuItems,
                  onItemTap: (context, item) => handleMenuAction(item),
                ),
                // Vista de historial
                HistoryView(
                  onStatusMessage: updateStatusMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
