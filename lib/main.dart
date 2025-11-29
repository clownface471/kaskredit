import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- 1. TAMBAHKAN IMPORT INI
import 'firebase_options.dart';
import 'core/navigation/app_pages.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/bindings/initial_binding.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // <--- 2. TAMBAHKAN BARIS INI
  // Ini wajib dipanggil jika menggunakan locale 'id_ID' (Indonesia)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KasKredit',
      theme: AppTheme.lightTheme,
      
      // Binding awal untuk AuthController dll
      initialBinding: InitialBinding(), 
      
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}