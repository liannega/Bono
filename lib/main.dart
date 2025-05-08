import 'package:bono/config/router/app_router.dart';
import 'package:bono/services/theme/theme_provider.dart';
import 'package:bono/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isWidgetEnabled = prefs.getBool('widget_enabled') ?? false;

  final savedThemeMode = prefs.getString('theme_mode');
  ThemeMode initialThemeMode;

  if (savedThemeMode == null) {
    initialThemeMode = ThemeMode.system;
  } else {
    initialThemeMode = savedThemeMode == 'dark'
        ? ThemeMode.dark
        : (savedThemeMode == 'light' ? ThemeMode.light : ThemeMode.system);
  }

  if (isWidgetEnabled) {
    try {
      await WidgetService.enableWidget();
    } catch (e) {
      print('Error al actualizar widget: $e');
    }
  }

  runApp(
    ProviderScope(
      child: MyApp(initialThemeMode: initialThemeMode),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final ThemeMode initialThemeMode;

  const MyApp({super.key, required this.initialThemeMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;

    Future.microtask(() {
      ref.read(themeModeProvider.notifier).state = _themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'BONO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.blue,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blue,
          surface: Colors.white,
          onSurface: Color(0xFF333333),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.montserrat(
            color: const Color(0xFF333333),
            fontSize: 18,
          ),
          bodyMedium: GoogleFonts.montserrat(
            color: const Color(0xFF333333),
            fontSize: 16,
          ),
          titleLarge: GoogleFonts.montserrat(
            color: const Color(0xFF333333),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.montserrat(
            color: const Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.blue),
        dialogBackgroundColor: Colors.white,
        dividerColor: Colors.grey.withOpacity(0.2),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF333333),
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF333333),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.blue,
          ),
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blue,
          surface: Color(0xFF333333),
          onSurface: Colors.white,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
          ),
          bodyMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 16,
          ),
          titleLarge: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardColor: const Color(0xFF424242),
        iconTheme: const IconThemeData(color: Colors.blue),
        dialogBackgroundColor: const Color(0xFF333333),
        dividerColor: Colors.grey.withOpacity(0.2),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
        ),
      ),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
