import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/shared/models/payment.dart';

part 'payment_providers.g.dart'; // Akan dibuat

// Provider untuk mengambil SEMUA riwayat pembayaran
@riverpod
Stream<List<Payment>> paymentHistory(Ref ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return repo.getAllPayments(userId);
}
