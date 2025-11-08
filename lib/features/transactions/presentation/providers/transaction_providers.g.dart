// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$transactionsWithDebtHash() =>
    r'3e35441b591a6cf2a12551af59f9caee69eddc35';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [transactionsWithDebt].
@ProviderFor(transactionsWithDebt)
const transactionsWithDebtProvider = TransactionsWithDebtFamily();

/// See also [transactionsWithDebt].
class TransactionsWithDebtFamily extends Family<AsyncValue<List<Transaction>>> {
  /// See also [transactionsWithDebt].
  const TransactionsWithDebtFamily();

  /// See also [transactionsWithDebt].
  TransactionsWithDebtProvider call(String customerId) {
    return TransactionsWithDebtProvider(customerId);
  }

  @override
  TransactionsWithDebtProvider getProviderOverride(
    covariant TransactionsWithDebtProvider provider,
  ) {
    return call(provider.customerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsWithDebtProvider';
}

/// See also [transactionsWithDebt].
class TransactionsWithDebtProvider
    extends AutoDisposeStreamProvider<List<Transaction>> {
  /// See also [transactionsWithDebt].
  TransactionsWithDebtProvider(String customerId)
    : this._internal(
        (ref) =>
            transactionsWithDebt(ref as TransactionsWithDebtRef, customerId),
        from: transactionsWithDebtProvider,
        name: r'transactionsWithDebtProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$transactionsWithDebtHash,
        dependencies: TransactionsWithDebtFamily._dependencies,
        allTransitiveDependencies:
            TransactionsWithDebtFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  TransactionsWithDebtProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    Stream<List<Transaction>> Function(TransactionsWithDebtRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsWithDebtProvider._internal(
        (ref) => create(ref as TransactionsWithDebtRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Transaction>> createElement() {
    return _TransactionsWithDebtProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsWithDebtProvider &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TransactionsWithDebtRef
    on AutoDisposeStreamProviderRef<List<Transaction>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _TransactionsWithDebtProviderElement
    extends AutoDisposeStreamProviderElement<List<Transaction>>
    with TransactionsWithDebtRef {
  _TransactionsWithDebtProviderElement(super.provider);

  @override
  String get customerId => (origin as TransactionsWithDebtProvider).customerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
