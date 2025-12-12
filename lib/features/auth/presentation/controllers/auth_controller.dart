import 'dart:async';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  void _setInitialScreen(User? user) {
    if (isLoading.value) {
      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        if (user == null) {
          Get.offAllNamed(AppRoutes.LOGIN);
        } else {
          Get.offAllNamed(AppRoutes.DASHBOARD);
        }
      });
    } else {
      if (user == null) {
        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    }
  }

  bool get isLoggedIn => firebaseUser.value != null;
  User? get currentUser => firebaseUser.value;
  String? get currentUserId => firebaseUser.value?.uid;

  /// Sign In dengan Timeout & Error Handling Lengkap
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Koneksi timeout');
        },
      );
      
    } on TimeoutException {
      Get.snackbar(
        'Timeout',
        'Koneksi ke server gagal. Periksa internet Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      
      Get.snackbar(
        'Login Gagal',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Register dengan Timeout & Error Handling
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      isLoading.value = true;
      
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Koneksi timeout');
        },
      );
      
      await credential.user?.updateDisplayName(name);
      
      Get.snackbar(
        'Berhasil',
        'Akun berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      );
      
    } on TimeoutException {
      Get.snackbar(
        'Timeout',
        'Koneksi ke server gagal. Periksa internet Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      
      Get.snackbar(
        'Registrasi Gagal',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Koneksi timeout');
        },
      );
      
      Get.snackbar(
        'Berhasil',
        'Email reset password telah dikirim',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      );
    } on TimeoutException {
      Get.snackbar(
        'Timeout',
        'Koneksi ke server gagal. Periksa internet Anda.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan';
      }
      
      Get.snackbar(
        'Gagal',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}