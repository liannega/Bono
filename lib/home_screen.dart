import 'package:bono/presentation/widgets/menu_lateral.dart';
import 'package:bono/presentation/widgets/shared/items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:url_launcher/url_launcher.dart';

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void handleMenuAction(BuildContext context, dynamic item) async {
    if (item.ussdCode != null) {
      final Uri ussdUri = Uri(scheme: 'tel', path: item.ussdCode!);
      if (await canLaunchUrl(ussdUri)) {
        await launchUrl(ussdUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo ejecutar el código USSD')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'BONO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
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
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _currentPage == 0 ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Icono de historial
                GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _currentPage == 1 ? Colors.blue : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 40,
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
                _buildMenuList(menuItems),
                // Vista de historial
                _buildMenuList(historyItems),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(List<dynamic> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: GestureDetector(
            onTap: () => handleMenuAction(context, item),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 28,
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
        );
      },
    );
  }
}



// import 'package:bono/home_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';


// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
//   late HomeController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = HomeController(this);
//     _controller.addListener(() {
//       if (mounted) setState(() {});
//     });
    
//     // Solicitar permisos al iniciar
//     _requestPermissions();
//   }
//   // Reemplaza el método _requestPermissions con esta versión:

// Future<void> _requestPermissions() async {
//   // Solicitar permisos necesarios para USSD
//   await Permission.phone.request();
// }
 

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor: const Color(0xFF121212),
//           appBar: AppBar(
//             title: const Text(
//               'BONO',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: const Color(0xFF121212),
//             elevation: 0,
//             leading: Builder(
//               builder: (context) => IconButton(
//                 icon: const Icon(Icons.menu, color: Colors.white),
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//               ),
//             ),
//           ),
//           drawer: CustomDrawer(
//             isDarkMode: _controller.isDarkMode,
//             onThemeChanged: (value) {
//               _controller.toggleTheme(value);
//             },
//           ),
//           body: Column(
//             children: [
//               // Iconos de navegación superiores
//               _buildTabIcons(),

//               // PageView con las dos vistas
//               Expanded(
//                 child: PageView(
//                   controller: _controller.pageController,
//                   children: [
//                     // Vista principal
//                     _buildMenuList(menuItems),
//                     // Vista de historial
//                     _buildMenuList(historyItems),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // Indicador de carga
//         if (_controller.isLoading)
//           Container(
//             color: Colors.black.withOpacity(0.5),
//             child: const Center(
//               child: CircularProgressIndicator(),
//             ),
//           ),
//       ],
//     );
//   }

//   // Widget para los iconos de navegación
//   Widget _buildTabIcons() {
//     return Container(
//       padding: const EdgeInsets.only(top: 10, bottom: 30),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Icono de teléfono
//           InkWell(
//             onTap: () => _controller.goToPage(0),
//             child: Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 color: _controller.currentPage == 0
//                     ? Colors.blue
//                     : const Color(0xFF121212),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.phone_android,
//                 color: Colors.white,
//                 size: 35,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           // Icono de historial
//           GestureDetector(
//             onTap: () => _controller.goToPage(1),
//             child: Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 color: _controller.currentPage == 1
//                     ? Colors.blue
//                     : const Color(0xFF121212),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.history,
//                 color: Colors.white,
//                 size: 35,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget para construir la lista de menú
//   Widget _buildMenuList(List<dynamic> items) {
//     return ListView.builder(
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//           child: GestureDetector(
//             onTap: () => _controller.handleMenuAction(context, item),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.blue,
//                   child: Icon(
//                     item.icon,
//                     color: Colors.white,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         item.title,
//                         style: GoogleFonts.montserrat(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.white,
//                         ),
//                       ),
//                       if (item.subtitle != null)
//                         Text(
//                           item.subtitle!,
//                           style: GoogleFonts.montserrat(
//                             fontSize: 14,
//                             color: Colors.grey,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (item.hasSubmenu)
//                   const Icon(
//                     Icons.chevron_right,
//                     color: Colors.blue,
//                     size: 30,
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

