import 'package:flutter/material.dart';
// HAPUS SEMUA IMPORT RIVERPOD DAN GO_ROUTER
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../providers/auth_providers.dart';

// UBAH JADI STATELESSWIDGET BIASA
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HAPUS SEMUA BLOK ref.listen(...)
    // Logika navigasi sudah pindah ke app.dart

    // Tampilkan UI Splash Screen
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 100, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              "KasKredit",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              "Kasir & Manajemen Utang",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("v1.0.0"),
          ],
        ),
      ),
    );
  }
}