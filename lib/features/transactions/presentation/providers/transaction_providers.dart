import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'transaction_providers.g.dart'; // Akan dibuat

// Provider untuk mengambil transaksi yg belum lunas per pelanggan
@riverpod
Stream<List<Transaction>> transactionsWithDebt(Ref ref, String customerId) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsWithDebt(customerId);
}

@riverpod
Stream<List<Transaction>> transactionHistory(Ref ref) {
  // Kita butuh akses ke repository dan user
  final repo = ref.watch(transactionRepositoryProvider);
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    return Stream.value([]);
  }
  
  // Panggil method baru dari repository
  return repo.getTransactionHistory(userId);
}