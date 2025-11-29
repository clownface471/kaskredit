import 'package:get/get.dart';
import 'package:kaskredit_1/features/auth/presentation/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Kita pasang permanent: true supaya AuthController tidak pernah dihapus dari memori
    // meskipun kita pindah-pindah halaman.
    Get.put(AuthController(), permanent: true);
  }
}