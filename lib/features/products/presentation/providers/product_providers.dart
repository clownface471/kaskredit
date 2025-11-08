import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/product_repository.dart';
import '../../../../shared/models/product.dart';

part 'product_providers.g.dart';

// Ini adalah provider Stream yang akan "ditonton" oleh UI
// Sesuai blueprint [cite: 733-739]
@Riverpod(keepAlive: true)
Stream<List<Product>> products(ProductsRef ref) {
  // 1. Dapatkan repository
  final productRepo = ref.watch(productRepositoryProvider);
  
  // 2. Dapatkan ID user yang sedang login
  final userId = ref.watch(currentUserProvider).value?.id;

  // 3. Jika user belum login, kembalikan stream kosong
  if (userId == null) {
    return Stream.value([]);
  }

  // 4. Jika sudah login, kembalikan stream produk milik user tsb
  return productRepo.getProducts(userId);
}