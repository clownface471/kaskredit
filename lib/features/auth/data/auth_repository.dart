import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk memantau status auth
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Fungsi Sign Up (Register)
  Future<void> signUp({
    required String email,
    required String password,
    required String shopName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Gagal membuat user, user null.');
      }

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'shopName': shopName,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception('Error SignUp: ${e.message}');
    } catch (e) {
      throw Exception('Error SignUp: ${e.toString()}');
    }
  }

  // Fungsi Sign In (Login)
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error SignIn: ${e.message}');
    } catch (e) {
      throw Exception('Error SignIn: ${e.toString()}');
    }
  }

  // Fungsi Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}