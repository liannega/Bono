import 'package:bono/config/utils/ussd_service.dart';
import 'package:bono/services/history_service.dart';
import 'package:bono/presentation/pages/history_view.dart';
import 'package:bono/services/theme/theme_provider.dart';
import 'package:bono/widgets/shared/items.dart';
import 'package:bono/widgets/shared/menu_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bono/presentation/pages/asterisco99_page.dart';

final currentPageProvider = StateProvider<int>((ref) => 0);

final executingUssdProvider = StateProvider<bool>((ref) => false);

final statusMessageProvider = StateProvider<String?>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 2, vsync: this);

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != ref.read(currentPageProvider)) {
        ref.read(currentPageProvider.notifier).state = page;
      }
    });

    _checkPermission();

    HistoryService.initialize();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await UssdService.hasCallPermission();
    if (!hasPermission) {
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
    if (item.title == "Asterisco 99") {
      await _handleAsterisco99();
      return;
    }

    if (item.ussdCode != null && !ref.read(executingUssdProvider)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            'Ejecutar ${item.title}',
            style: GoogleFonts.montserrat(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '¿Deseas ejecutar el código ${item.ussdCode}?',
            style: GoogleFonts.montserrat(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              letterSpacing: -0.3,
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
            ),
          ],
        ),
      );

      if (confirm != true) return;

      ref.read(executingUssdProvider.notifier).state = true;
      ref.read(statusMessageProvider.notifier).state =
          "Ejecutando código USSD...";

      try {
        var ussdCode = item.ussdCode!.trim();
        if (!ussdCode.startsWith("*") && !ussdCode.startsWith("#")) {
          ussdCode = "*$ussdCode";
        }

        if (!ussdCode.endsWith("#")) {
          ussdCode = "$ussdCode#";
        }

        final success = await UssdService.executeUssd(ussdCode);

        if (!mounted) return;

        if (success) {
          ref.read(statusMessageProvider.notifier).state =
              "Código USSD ejecutado correctamente";

          HistoryService.addToHistory(item, ussdCode);
        } else {
          ref.read(statusMessageProvider.notifier).state =
              "Error al ejecutar el código USSD";
        }
      } catch (e) {
        if (mounted) {
          ref.read(statusMessageProvider.notifier).state =
              "Error: ${e.toString()}";
        }
      } finally {
        if (mounted) {
          ref.read(executingUssdProvider.notifier).state = false;

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              ref.read(statusMessageProvider.notifier).state = null;
            }
          });
        }
      }
    }
  }

  Future<void> _handleAsterisco99() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Asterisco99Page(),
      ),
    );
  }

  void updateStatusMessage(String message) {}

  void _toggleTheme() {
    final currentThemeMode = ref.read(themeModeProvider);
    ThemeMode newThemeMode;

    switch (currentThemeMode) {
      case ThemeMode.system:
        newThemeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newThemeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
      default:
        newThemeMode = ThemeMode.system;
        break;
    }

    ref.read(themeModeProvider.notifier).state = newThemeMode;
    saveThemeMode(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = isDarkMode(context);
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.light:
        themeIcon = Icons.dark_mode;
        break;
      case ThemeMode.dark:
        themeIcon = Icons.light_mode;
        break;
      case ThemeMode.system:
      default:
        themeIcon = isDark ? Icons.light_mode : Icons.dark_mode;
        break;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'BONO',
          style: GoogleFonts.montserrat(
            color: Colors.blue,
            fontSize: 23,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeIcon,
              color: Colors.blue,
            ),
            onPressed: _toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: currentPage == 0 ? Colors.blue : backgroundColor,
                      shape: BoxShape.circle,
                      border: currentPage != 0
                          ? Border.all(color: Colors.blue.withOpacity(0.3))
                          : null,
                      boxShadow: currentPage == 0
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: currentPage == 0 ? Colors.white : Colors.blue,
                      size: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: currentPage == 1 ? Colors.blue : backgroundColor,
                      shape: BoxShape.circle,
                      border: currentPage != 1
                          ? Border.all(color: Colors.blue.withOpacity(0.3))
                          : null,
                      boxShadow: currentPage == 1
                          ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.history,
                      color: currentPage == 1 ? Colors.white : Colors.blue,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                MenuList(
                  items: menuItems,
                  onItemTap: (context, item) => handleMenuAction(item),
                ),
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
