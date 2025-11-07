import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/auth_repository.dart';
import '../../../../shared/models/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'auth_providers.g.dart'; // Dibuat otomatis

// 1. Provider untuk status auth (User dari Firebase Auth)
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

// 2. Provider untuk profil user (AppUser dari Firestore)
@Riverpod(keepAlive: true)
Stream<AppUser?> currentUser(Ref ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final firestore = FirebaseFirestore.instance;

  // Pantau perubahan status auth
  return authRepo.authStateChanges().asyncMap((firebaseUser) async {
    if (firebaseUser == null) {
      return null; // Tidak ada user login
    }
    
    // Jika ada user login, ambil datanya dari Firestore
    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) {
      return null; // Data di firestore belum ada (jarang terjadi)
    }
    
    // Kembalikan sebagai model AppUser kita
    return AppUser.fromFirestore(doc);
  });
}