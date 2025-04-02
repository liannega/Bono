import 'package:bono/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

final approuter = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const HomePage(),
  ),
]);


