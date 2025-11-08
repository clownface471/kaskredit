import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

// 1. IMPORT FILE YANG DIBUAT OLEH FLUTTERFIRE
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. GUNAKAN OPTIONS DI SINI
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // <-- "Buka" baris ini
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}