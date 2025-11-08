// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customersHash() => r'9b79733662760ee3bcc7100907e36c53b5a6ee54';

/// See also [customers].
@ProviderFor(customers)
final customersProvider = StreamProvider<List<Customer>>.internal(
  customers,
  name: r'customersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomersRef = StreamProviderRef<List<Customer>>;
String _$customersWithDebtHash() => r'f25462e6c6abe257fe70cf6c22a42d92683355d7';

/// See also [customersWithDebt].
@ProviderFor(customersWithDebt)
final customersWithDebtProvider =
    AutoDisposeProvider<AsyncValue<List<Customer>>>.internal(
      customersWithDebt,
      name: r'customersWithDebtProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customersWithDebtHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomersWithDebtRef =
    AutoDisposeProviderRef<AsyncValue<List<Customer>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
