import 'package:bono/presentation/pages/asterisco99_page.dart';
import 'package:bono/presentation/pages/home_page.dart';
import 'package:bono/presentation/pages/numero_oculto_page.dart';
import 'package:bono/presentation/pages/numeros_utiles_page.dart';
import 'package:bono/presentation/pages/transferir_saldo_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Ruta principal - HomePage
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
      routes: [
        // Rutas anidadas

        GoRoute(
          path: 'asterisco99',
          name: 'asterisco99',
          builder: (context, state) => const Asterisco99Page(),
        ),
        GoRoute(
          path: 'numero-oculto',
          name: 'numero-oculto',
          builder: (context, state) => const NumeroOcultoPage(),
        ),
        GoRoute(
          path: 'numeros-utiles',
          name: 'numeros-utiles',
          builder: (context, state) => const NumerosUtilesPage(),
        ),
        GoRoute(
          path: 'transferir-saldo',
          name: 'transferir-saldo',
          builder: (context, state) => const TransferirSaldoPage(),
        ),
      ],
    ),
  ],
  // Configuración de errores
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF333333),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Página no encontrada',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
);
