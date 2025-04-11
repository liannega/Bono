import 'package:bono/config/router/app_router.dart';
import 'package:bono/services/theme/theme_provider.dart';
import 'package:bono/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Asegurarse de que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar si el widget está habilitado en las preferencias
  final prefs = await SharedPreferences.getInstance();
  final isWidgetEnabled = prefs.getBool('widget_enabled') ?? false;
  final isDarkMode = prefs.getBool('is_dark_mode') ?? true;

  // Si el widget está habilitado, actualizarlo
  if (isWidgetEnabled) {
    try {
      await WidgetService.enableWidget();
    } catch (e) {
      print('Error al actualizar widget: $e');
    }
  }

  runApp(
    ProviderScope(
      child: MyApp(initialDarkMode: isDarkMode),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool initialDarkMode;

  const MyApp({super.key, required this.initialDarkMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Inicializamos el provider con el valor inicial
    Future.microtask(() {
      ref.read(isDarkModeProvider.notifier).state = widget.initialDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp.router(
      title: 'BONO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor:
            isDarkMode ? const Color(0xFF333333) : Colors.white,
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: isDarkMode ? const Color(0xFF333333) : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        colorScheme: isDarkMode
            ? const ColorScheme.dark(
                primary: Colors.blue,
                secondary: Colors.blue,
              )
            : const ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.blue,
              ),
      ),
      routerConfig: appRouter,
    );
  }
}
