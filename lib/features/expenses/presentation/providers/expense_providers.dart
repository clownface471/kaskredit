import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/expenses/data/expense_repository.dart';
import 'package:kaskredit_1/shared/models/expense.dart';

part 'expense_providers.g.dart'; // Akan dibuat

// Provider Stream yang akan "ditonton" oleh UI
@riverpod
Stream<List<Expense>> expenses(Ref ref) {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return expenseRepo.getExpenses(userId);
}