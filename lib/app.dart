import 'package:flutter/material.dart';
import 'package:kaskredit_1/core/navigation/router.dart';
// 1. IMPORT YANG KITA BUTUHKAN
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';

// 2. UBAH JADI CONSUMERWIDGET
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  // 3. TAMBAHKAN WIDGETREF
  Widget build(BuildContext context, WidgetRef ref) {
    
    // 4. TAMBAHKAN LISTENER GLOBAL DI SINI
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        // Jika user login, paksa ke dashboard
        router.go('/dashboard');
      } else {
        // Jika user logout, paksa ke login
        router.go('/login');
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'KasKredit',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}