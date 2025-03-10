import 'package:bono/home_screen.dart';
import 'package:go_router/go_router.dart';

final approuter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomePage(),
  ),
]);
