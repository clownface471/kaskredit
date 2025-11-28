// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return _Receipt.fromJson(json);
}

/// @nodoc
mixin _$Receipt {
  Transaction get transaction => throw _privateConstructorUsedError;
  String get shopName => throw _privateConstructorUsedError;
  String? get shopAddress => throw _privateConstructorUsedError;
  String? get shopPhone => throw _privateConstructorUsedError;
  String? get footerNote => throw _privateConstructorUsedError;

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptCopyWith<Receipt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptCopyWith<$Res> {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) then) =
      _$ReceiptCopyWithImpl<$Res, Receipt>;
  @useResult
  $Res call({
    Transaction transaction,
    String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  });

  $TransactionCopyWith<$Res> get transaction;
}

/// @nodoc
class _$ReceiptCopyWithImpl<$Res, $Val extends Receipt>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transaction = null,
    Object? shopName = null,
    Object? shopAddress = freezed,
    Object? shopPhone = freezed,
    Object? footerNote = freezed,
  }) {
    return _then(
      _value.copyWith(
            transaction: null == transaction
                ? _value.transaction
                : transaction // ignore: cast_nullable_to_non_nullable
                      as Transaction,
            shopName: null == shopName
                ? _value.shopName
                : shopName // ignore: cast_nullable_to_non_nullable
                      as String,
            shopAddress: freezed == shopAddress
                ? _value.shopAddress
                : shopAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            shopPhone: freezed == shopPhone
                ? _value.shopPhone
                : shopPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            footerNote: freezed == footerNote
                ? _value.footerNote
                : footerNote // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransactionCopyWith<$Res> get transaction {
    return $TransactionCopyWith<$Res>(_value.transaction, (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReceiptImplCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$$ReceiptImplCopyWith(
    _$ReceiptImpl value,
    $Res Function(_$ReceiptImpl) then,
  ) = __$$ReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Transaction transaction,
    String shopName,
    String? shopAddress,
    String? shopPhone,
    String? footerNote,
  });

  @override
  $TransactionCopyWith<$Res> get transaction;
}

/// @nodoc
class __$$ReceiptImplCopyWithImpl<$Res>
    extends _$ReceiptCopyWithImpl<$Res, _$ReceiptImpl>
    implements _$$ReceiptImplCopyWith<$Res> {
  __$$ReceiptImplCopyWithImpl(
    _$ReceiptImpl _value,
    $Res Function(_$ReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transaction = null,
    Object? shopName = null,
    Object? shopAddress = freezed,
    Object? shopPhone = freezed,
    Object? footerNote = freezed,
  }) {
    return _then(
      _$ReceiptImpl(
        transaction: null == transaction
            ? _value.transaction
            : transaction // ignore: cast_nullable_to_non_nullable
                  as Transaction,
        shopName: null == shopName
            ? _value.shopName
            : shopName // ignore: cast_nullable_to_non_nullable
                  as String,
        shopAddress: freezed == shopAddress
            ? _value.shopAddress
            : shopAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        shopPhone: freezed == shopPhone
            ? _value.shopPhone
            : shopPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        footerNote: freezed == footerNote
            ? _value.footerNote
            : footerNote // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptImpl implements _Receipt {
  const _$ReceiptImpl({
    required this.transaction,
    required this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.footerNote,
  });

  factory _$ReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptImplFromJson(json);

  @override
  final Transaction transaction;
  @override
  final String shopName;
  @override
  final String? shopAddress;
  @override
  final String? shopPhone;
  @override
  final String? footerNote;

  @override
  String toString() {
    return 'Receipt(transaction: $transaction, shopName: $shopName, shopAddress: $shopAddress, shopPhone: $shopPhone, footerNote: $footerNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptImpl &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.shopName, shopName) ||
                other.shopName == shopName) &&
            (identical(other.shopAddress, shopAddress) ||
                other.shopAddress == shopAddress) &&
            (identical(other.shopPhone, shopPhone) ||
                other.shopPhone == shopPhone) &&
            (identical(other.footerNote, footerNote) ||
                other.footerNote == footerNote));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    transaction,
    shopName,
    shopAddress,
    shopPhone,
    footerNote,
  );

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      __$$ReceiptImplCopyWithImpl<_$ReceiptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptImplToJson(this);
  }
}

abstract class _Receipt implements Receipt {
  const factory _Receipt({
    required final Transaction transaction,
    required final String shopName,
    final String? shopAddress,
    final String? shopPhone,
    final String? footerNote,
  }) = _$ReceiptImpl;

  factory _Receipt.fromJson(Map<String, dynamic> json) = _$ReceiptImpl.fromJson;

  @override
  Transaction get transaction;
  @override
  String get shopName;
  @override
  String? get shopAddress;
  @override
  String? get shopPhone;
  @override
  String? get footerNote;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
