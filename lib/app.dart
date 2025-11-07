import 'package:flutter/material.dart';
import 'core/navigation/router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Gunakan router config di sini
      debugShowCheckedModeBanner: false,
      title: 'KasKredit',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}