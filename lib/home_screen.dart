import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/history_service.dart';
import 'package:bono/presentation/views/history_view.dart';
import 'package:bono/presentation/widgets/menu_lateral.dart';
import 'package:bono/presentation/widgets/shared/items.dart';
import 'package:bono/presentation/widgets/shared/menu_list.dart';
import 'package:flutter/material.dart';

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
    if (item.ussdCode != null && !_isExecutingUssd) {
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

  // Método para actualizar el mensaje de estado desde la vista de historial
  void updateStatusMessage(String message) {
    setState(() {
      _statusMessage = message;
    });

    // Limpiar el mensaje después de 3 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'BONO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w400,
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
