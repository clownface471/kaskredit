import 'package:flutter/material.dart';
import 'package:kaskredit_1/core/navigation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/core/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.valueOrNull;
      if (user != null) {
        router.go('/dashboard');
      } else {
        router.go('/login');
      }
    });

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'KasKredit',
      theme: AppTheme.lightTheme,
    );
  }
}