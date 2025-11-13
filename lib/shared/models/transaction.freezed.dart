// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get transactionNumber => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  String? get customerName =>
      throw _privateConstructorUsedError; // Denormalized
  List<TransactionItem> get items =>
      throw _privateConstructorUsedError; // List dari sub-model
  double get totalAmount => throw _privateConstructorUsedError;
  double get totalProfit => throw _privateConstructorUsedError;
  PaymentStatus get paymentStatus => throw _privateConstructorUsedError;
  PaymentType get paymentType => throw _privateConstructorUsedError;
  double get downPayment =>
      throw _privateConstructorUsedError; // Uang Muka (DP)
  double get interestRate =>
      throw _privateConstructorUsedError; // Bunga (misal: 10 untuk 10%)
  int get tenor =>
      throw _privateConstructorUsedError; // Jangka waktu (misal: 3 untuk 3 bulan)
  double get paidAmount => throw _privateConstructorUsedError;
  double get remainingDebt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get transactionDate => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get dueDate => throw _privateConstructorUsedError; // Opsional untuk kredit
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String userId,
    String transactionNumber,
    String? customerId,
    String? customerName,
    List<TransactionItem> items,
    double totalAmount,
    double totalProfit,
    PaymentStatus paymentStatus,
    PaymentType paymentType,
    double downPayment,
    double interestRate,
    int tenor,
    double paidAmount,
    double remainingDebt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime transactionDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? dueDate,
    String? notes,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime updatedAt,
  });
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? transactionNumber = null,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? items = null,
    Object? totalAmount = null,
    Object? totalProfit = null,
    Object? paymentStatus = null,
    Object? paymentType = null,
    Object? downPayment = null,
    Object? interestRate = null,
    Object? tenor = null,
    Object? paidAmount = null,
    Object? remainingDebt = null,
    Object? transactionDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            transactionNumber: null == transactionNumber
                ? _value.transactionNumber
                : transactionNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: freezed == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<TransactionItem>,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfit: null == totalProfit
                ? _value.totalProfit
                : totalProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentStatus: null == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as PaymentStatus,
            paymentType: null == paymentType
                ? _value.paymentType
                : paymentType // ignore: cast_nullable_to_non_nullable
                      as PaymentType,
            downPayment: null == downPayment
                ? _value.downPayment
                : downPayment // ignore: cast_nullable_to_non_nullable
                      as double,
            interestRate: null == interestRate
                ? _value.interestRate
                : interestRate // ignore: cast_nullable_to_non_nullable
                      as double,
            tenor: null == tenor
                ? _value.tenor
                : tenor // ignore: cast_nullable_to_non_nullable
                      as int,
            paidAmount: null == paidAmount
                ? _value.paidAmount
                : paidAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            remainingDebt: null == remainingDebt
                ? _value.remainingDebt
                : remainingDebt // ignore: cast_nullable_to_non_nullable
                      as double,
            transactionDate: null == transactionDate
                ? _value.transactionDate
                : transactionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(includeFromJson: false, includeToJson: false) String? id,
    String userId,
    String transactionNumber,
    String? customerId,
    String? customerName,
    List<TransactionItem> items,
    double totalAmount,
    double totalProfit,
    PaymentStatus paymentStatus,
    PaymentType paymentType,
    double downPayment,
    double interestRate,
    int tenor,
    double paidAmount,
    double remainingDebt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime transactionDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    DateTime? dueDate,
    String? notes,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? transactionNumber = null,
    Object? customerId = freezed,
    Object? customerName = freezed,
    Object? items = null,
    Object? totalAmount = null,
    Object? totalProfit = null,
    Object? paymentStatus = null,
    Object? paymentType = null,
    Object? downPayment = null,
    Object? interestRate = null,
    Object? tenor = null,
    Object? paidAmount = null,
    Object? remainingDebt = null,
    Object? transactionDate = null,
    Object? dueDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$TransactionImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        transactionNumber: null == transactionNumber
            ? _value.transactionNumber
            : transactionNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: freezed == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TransactionItem>,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfit: null == totalProfit
            ? _value.totalProfit
            : totalProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentStatus: null == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as PaymentStatus,
        paymentType: null == paymentType
            ? _value.paymentType
            : paymentType // ignore: cast_nullable_to_non_nullable
                  as PaymentType,
        downPayment: null == downPayment
            ? _value.downPayment
            : downPayment // ignore: cast_nullable_to_non_nullable
                  as double,
        interestRate: null == interestRate
            ? _value.interestRate
            : interestRate // ignore: cast_nullable_to_non_nullable
                  as double,
        tenor: null == tenor
            ? _value.tenor
            : tenor // ignore: cast_nullable_to_non_nullable
                  as int,
        paidAmount: null == paidAmount
            ? _value.paidAmount
            : paidAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        remainingDebt: null == remainingDebt
            ? _value.remainingDebt
            : remainingDebt // ignore: cast_nullable_to_non_nullable
                  as double,
        transactionDate: null == transactionDate
            ? _value.transactionDate
            : transactionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl({
    @JsonKey(includeFromJson: false, includeToJson: false) this.id,
    required this.userId,
    required this.transactionNumber,
    this.customerId,
    this.customerName,
    required final List<TransactionItem> items,
    required this.totalAmount,
    required this.totalProfit,
    required this.paymentStatus,
    required this.paymentType,
    this.downPayment = 0.0,
    this.interestRate = 0.0,
    this.tenor = 0,
    this.paidAmount = 0.0,
    this.remainingDebt = 0.0,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.transactionDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    this.dueDate,
    this.notes,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.updatedAt,
  }) : _items = items;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? id;
  @override
  final String userId;
  @override
  final String transactionNumber;
  @override
  final String? customerId;
  @override
  final String? customerName;
  // Denormalized
  final List<TransactionItem> _items;
  // Denormalized
  @override
  List<TransactionItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  // List dari sub-model
  @override
  final double totalAmount;
  @override
  final double totalProfit;
  @override
  final PaymentStatus paymentStatus;
  @override
  final PaymentType paymentType;
  @override
  @JsonKey()
  final double downPayment;
  // Uang Muka (DP)
  @override
  @JsonKey()
  final double interestRate;
  // Bunga (misal: 10 untuk 10%)
  @override
  @JsonKey()
  final int tenor;
  // Jangka waktu (misal: 3 untuk 3 bulan)
  @override
  @JsonKey()
  final double paidAmount;
  @override
  @JsonKey()
  final double remainingDebt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime transactionDate;
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  final DateTime? dueDate;
  // Opsional untuk kredit
  @override
  final String? notes;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Transaction(id: $id, userId: $userId, transactionNumber: $transactionNumber, customerId: $customerId, customerName: $customerName, items: $items, totalAmount: $totalAmount, totalProfit: $totalProfit, paymentStatus: $paymentStatus, paymentType: $paymentType, downPayment: $downPayment, interestRate: $interestRate, tenor: $tenor, paidAmount: $paidAmount, remainingDebt: $remainingDebt, transactionDate: $transactionDate, dueDate: $dueDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.transactionNumber, transactionNumber) ||
                other.transactionNumber == transactionNumber) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.totalProfit, totalProfit) ||
                other.totalProfit == totalProfit) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentType, paymentType) ||
                other.paymentType == paymentType) &&
            (identical(other.downPayment, downPayment) ||
                other.downPayment == downPayment) &&
            (identical(other.interestRate, interestRate) ||
                other.interestRate == interestRate) &&
            (identical(other.tenor, tenor) || other.tenor == tenor) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.remainingDebt, remainingDebt) ||
                other.remainingDebt == remainingDebt) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    userId,
    transactionNumber,
    customerId,
    customerName,
    const DeepCollectionEquality().hash(_items),
    totalAmount,
    totalProfit,
    paymentStatus,
    paymentType,
    downPayment,
    interestRate,
    tenor,
    paidAmount,
    remainingDebt,
    transactionDate,
    dueDate,
    notes,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction({
    @JsonKey(includeFromJson: false, includeToJson: false) final String? id,
    required final String userId,
    required final String transactionNumber,
    final String? customerId,
    final String? customerName,
    required final List<TransactionItem> items,
    required final double totalAmount,
    required final double totalProfit,
    required final PaymentStatus paymentStatus,
    required final PaymentType paymentType,
    final double downPayment,
    final double interestRate,
    final int tenor,
    final double paidAmount,
    final double remainingDebt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime transactionDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromTimestamp,
      toJson: _nullableDateTimeToTimestamp,
    )
    final DateTime? dueDate,
    final String? notes,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime createdAt,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime updatedAt,
  }) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get id;
  @override
  String get userId;
  @override
  String get transactionNumber;
  @override
  String? get customerId;
  @override
  String? get customerName; // Denormalized
  @override
  List<TransactionItem> get items; // List dari sub-model
  @override
  double get totalAmount;
  @override
  double get totalProfit;
  @override
  PaymentStatus get paymentStatus;
  @override
  PaymentType get paymentType;
  @override
  double get downPayment; // Uang Muka (DP)
  @override
  double get interestRate; // Bunga (misal: 10 untuk 10%)
  @override
  int get tenor; // Jangka waktu (misal: 3 untuk 3 bulan)
  @override
  double get paidAmount;
  @override
  double get remainingDebt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get transactionDate;
  @override
  @JsonKey(
    fromJson: _nullableDateTimeFromTimestamp,
    toJson: _nullableDateTimeToTimestamp,
  )
  DateTime? get dueDate; // Opsional untuk kredit
  @override
  String? get notes;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get createdAt;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get updatedAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
