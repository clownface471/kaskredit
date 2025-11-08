import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:riverpod_annotation/riverpod_annotation.dart';
// GANTI SEMUA IMPORT DI BAWAH INI MENJADI RELATIVE
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/customer_repository.dart';
import '../../../../shared/models/customer.dart';

part 'customer_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<List<Customer>> customers(Ref ref) {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return customerRepo.getCustomers(userId);
}

@riverpod
AsyncValue<List<Customer>> customersWithDebt(Ref ref) {
  // Ambil AsyncValue dari provider pelanggan utama
  final customersAsync = ref.watch(customersProvider);

  // Kita transform AsyncValue-nya menggunakan .when()
  return customersAsync.when(
    data: (customers) {
      // Logika filter kita pindah ke sini
      final debtors = customers.where((c) => c.totalDebt > 0).toList();
      debtors.sort((a, b) => b.totalDebt.compareTo(a.totalDebt));
      // Kembalikan sebagai AsyncValue data yang baru
      return AsyncValue.data(debtors);
    },
    // Teruskan state loading dan error
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
  );
}