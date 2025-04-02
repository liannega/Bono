import 'package:bono/presentation/pages/home_page.dart';
import 'package:bono/services/widget_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  // Asegurarse de que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar si el widget está habilitado en las preferencias
  final prefs = await SharedPreferences.getInstance();
  final isWidgetEnabled = prefs.getBool('widget_enabled') ?? false;

  // Si el widget está habilitado, actualizarlo
  if (isWidgetEnabled) {
    try {
      await WidgetService.enableWidget();
    } catch (e) {
      print('Error al actualizar widget: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BONO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}
