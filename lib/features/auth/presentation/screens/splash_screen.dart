import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 2. Setup listener untuk navigasi
    // Ini akan menavigasi SEGERA setelah status auth diketahui
    ref.listen(authStateChangesProvider, (previous, next) {
      next.when(
        data: (user) {
          // Navigasi tidak boleh dalam build, jadi kita pakai Future.microtask
          Future.microtask(() {
            if (!context.mounted) return;
            if (user != null) {
              // User login
              // context.go('/dashboard'); // Nanti kita buka
            } else {
              // User logout
              context.go('/login'); // Nanti kita buka
            }
          });
        },
        loading: () {}, // Biarkan loading
        error: (e, s) {
          // Handle error, mungkin navigasi ke login
          Future.microtask(() {
            // TAMBAHKAN PENGECEKAN INI JUGA:
            if (!context.mounted) return; 
            context.go('/login');
          });
        },
      );
    });

    // 3. Tampilkan UI Splash Screen
    // Sesuai blueprint [cite: 255-260]
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // [cite: 265] (Ganti Icon dengan Image.asset('assets/logo.png') 
            // jika Anda sudah punya logo)
            const Icon(Icons.storefront, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              "KasKredit", // [cite: 257]
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              "Kasir & Manajemen Utang", // [cite: 258]
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(), // [cite: 259]
            const SizedBox(height: 16),
            const Text("v1.0.0"), // [cite: 260]
          ],
        ),
      ),
    );
  }
}