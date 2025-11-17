// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentHistoryHash() => r'4182e538fb36ca100af6142eadb870d6fd313f87';

/// See also [paymentHistory].
@ProviderFor(paymentHistory)
final paymentHistoryProvider =
    AutoDisposeStreamProvider<List<Payment>>.internal(
      paymentHistory,
      name: r'paymentHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentHistoryRef = AutoDisposeStreamProviderRef<List<Payment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
