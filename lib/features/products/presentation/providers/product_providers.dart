import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/product_repository.dart';
import '../../../../shared/models/product.dart';
part 'product_providers.g.dart';

// Ini adalah provider Stream yang akan "ditonton" oleh UI
// Sesuai blueprint [cite: 733-739]
@Riverpod(keepAlive: true)
Stream<List<Product>> products(Ref ref) {
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

@riverpod
AsyncValue<List<Product>> productSearch(Ref ref, String query) {
  // 1. Ambil AsyncValue dari provider produk utama
  final productsAsync = ref.watch(productsProvider);

  // 2. Jika tidak ada query, kembalikan saja AsyncValue aslinya
  if (query.isEmpty) {
    return productsAsync;
  }

  // 3. Jika ada query, transform AsyncValue-nya
  return productsAsync.when(
    data: (products) {
      // Filter list-nya
      final filtered = products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // Kembalikan sebagai data baru
      return AsyncValue.data(filtered);
    },
    // Teruskan state loading dan error
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
}