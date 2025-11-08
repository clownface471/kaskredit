import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/customers/data/customer_repository.dart';
import 'package:kaskredit_1/shared/models/customer.dart';

part 'customer_providers.g.dart';

// Provider Stream yang akan "ditonton" oleh UI
@Riverpod(keepAlive: true)
Stream<List<Customer>> customers(Ref ref) {
  final customerRepo = ref.watch(customerRepositoryProvider);
  final userId = ref.watch(currentUserProvider).value?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return customerRepo.getCustomers(userId);
}