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