import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';// Kita akan buat file ini setelah ini
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
// import 'package:kaskredit/features/dashboard/presentation/screens/dashboard_screen.dart';

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/splash', // Mulai dari splash screen
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    // GoRoute(
    //   path: '/dashboard',
    //   builder: (context, state) => const DashboardScreen(),
    // ),
  ],
);