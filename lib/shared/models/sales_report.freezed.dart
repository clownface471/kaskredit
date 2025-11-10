// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) {
  return _DailyStats.fromJson(json);
}

/// @nodoc
mixin _$DailyStats {
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get date => throw _privateConstructorUsedError;
  double get totalSales => throw _privateConstructorUsedError;
  double get totalProfit => throw _privateConstructorUsedError;

  /// Serializes this DailyStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatsCopyWith<DailyStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatsCopyWith<$Res> {
  factory $DailyStatsCopyWith(
    DailyStats value,
    $Res Function(DailyStats) then,
  ) = _$DailyStatsCopyWithImpl<$Res, DailyStats>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime date,
    double totalSales,
    double totalProfit,
  });
}

/// @nodoc
class _$DailyStatsCopyWithImpl<$Res, $Val extends DailyStats>
    implements $DailyStatsCopyWith<$Res> {
  _$DailyStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalSales = null,
    Object? totalProfit = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalSales: null == totalSales
                ? _value.totalSales
                : totalSales // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfit: null == totalProfit
                ? _value.totalProfit
                : totalProfit // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyStatsImplCopyWith<$Res>
    implements $DailyStatsCopyWith<$Res> {
  factory _$$DailyStatsImplCopyWith(
    _$DailyStatsImpl value,
    $Res Function(_$DailyStatsImpl) then,
  ) = __$$DailyStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime date,
    double totalSales,
    double totalProfit,
  });
}

/// @nodoc
class __$$DailyStatsImplCopyWithImpl<$Res>
    extends _$DailyStatsCopyWithImpl<$Res, _$DailyStatsImpl>
    implements _$$DailyStatsImplCopyWith<$Res> {
  __$$DailyStatsImplCopyWithImpl(
    _$DailyStatsImpl _value,
    $Res Function(_$DailyStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalSales = null,
    Object? totalProfit = null,
  }) {
    return _then(
      _$DailyStatsImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalSales: null == totalSales
            ? _value.totalSales
            : totalSales // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfit: null == totalProfit
            ? _value.totalProfit
            : totalProfit // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatsImpl implements _DailyStats {
  const _$DailyStatsImpl({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.date,
    required this.totalSales,
    required this.totalProfit,
  });

  factory _$DailyStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatsImplFromJson(json);

  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime date;
  @override
  final double totalSales;
  @override
  final double totalProfit;

  @override
  String toString() {
    return 'DailyStats(date: $date, totalSales: $totalSales, totalProfit: $totalProfit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.totalProfit, totalProfit) ||
                other.totalProfit == totalProfit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, totalSales, totalProfit);

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      __$$DailyStatsImplCopyWithImpl<_$DailyStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatsImplToJson(this);
  }
}

abstract class _DailyStats implements DailyStats {
  const factory _DailyStats({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime date,
    required final double totalSales,
    required final double totalProfit,
  }) = _$DailyStatsImpl;

  factory _DailyStats.fromJson(Map<String, dynamic> json) =
      _$DailyStatsImpl.fromJson;

  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get date;
  @override
  double get totalSales;
  @override
  double get totalProfit;

  /// Create a copy of DailyStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatsImplCopyWith<_$DailyStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductStats _$ProductStatsFromJson(Map<String, dynamic> json) {
  return _ProductStats.fromJson(json);
}

/// @nodoc
mixin _$ProductStats {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantitySold => throw _privateConstructorUsedError;
  double get totalSales => throw _privateConstructorUsedError;
  double get totalProfit => throw _privateConstructorUsedError;

  /// Serializes this ProductStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductStatsCopyWith<ProductStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductStatsCopyWith<$Res> {
  factory $ProductStatsCopyWith(
    ProductStats value,
    $Res Function(ProductStats) then,
  ) = _$ProductStatsCopyWithImpl<$Res, ProductStats>;
  @useResult
  $Res call({
    String productId,
    String productName,
    int quantitySold,
    double totalSales,
    double totalProfit,
  });
}

/// @nodoc
class _$ProductStatsCopyWithImpl<$Res, $Val extends ProductStats>
    implements $ProductStatsCopyWith<$Res> {
  _$ProductStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantitySold = null,
    Object? totalSales = null,
    Object? totalProfit = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            quantitySold: null == quantitySold
                ? _value.quantitySold
                : quantitySold // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSales: null == totalSales
                ? _value.totalSales
                : totalSales // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfit: null == totalProfit
                ? _value.totalProfit
                : totalProfit // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductStatsImplCopyWith<$Res>
    implements $ProductStatsCopyWith<$Res> {
  factory _$$ProductStatsImplCopyWith(
    _$ProductStatsImpl value,
    $Res Function(_$ProductStatsImpl) then,
  ) = __$$ProductStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String productName,
    int quantitySold,
    double totalSales,
    double totalProfit,
  });
}

/// @nodoc
class __$$ProductStatsImplCopyWithImpl<$Res>
    extends _$ProductStatsCopyWithImpl<$Res, _$ProductStatsImpl>
    implements _$$ProductStatsImplCopyWith<$Res> {
  __$$ProductStatsImplCopyWithImpl(
    _$ProductStatsImpl _value,
    $Res Function(_$ProductStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantitySold = null,
    Object? totalSales = null,
    Object? totalProfit = null,
  }) {
    return _then(
      _$ProductStatsImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        quantitySold: null == quantitySold
            ? _value.quantitySold
            : quantitySold // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSales: null == totalSales
            ? _value.totalSales
            : totalSales // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfit: null == totalProfit
            ? _value.totalProfit
            : totalProfit // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductStatsImpl implements _ProductStats {
  const _$ProductStatsImpl({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalSales,
    required this.totalProfit,
  });

  factory _$ProductStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductStatsImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantitySold;
  @override
  final double totalSales;
  @override
  final double totalProfit;

  @override
  String toString() {
    return 'ProductStats(productId: $productId, productName: $productName, quantitySold: $quantitySold, totalSales: $totalSales, totalProfit: $totalProfit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductStatsImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantitySold, quantitySold) ||
                other.quantitySold == quantitySold) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.totalProfit, totalProfit) ||
                other.totalProfit == totalProfit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    productName,
    quantitySold,
    totalSales,
    totalProfit,
  );

  /// Create a copy of ProductStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductStatsImplCopyWith<_$ProductStatsImpl> get copyWith =>
      __$$ProductStatsImplCopyWithImpl<_$ProductStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductStatsImplToJson(this);
  }
}

abstract class _ProductStats implements ProductStats {
  const factory _ProductStats({
    required final String productId,
    required final String productName,
    required final int quantitySold,
    required final double totalSales,
    required final double totalProfit,
  }) = _$ProductStatsImpl;

  factory _ProductStats.fromJson(Map<String, dynamic> json) =
      _$ProductStatsImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantitySold;
  @override
  double get totalSales;
  @override
  double get totalProfit;

  /// Create a copy of ProductStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductStatsImplCopyWith<_$ProductStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SalesReport _$SalesReportFromJson(Map<String, dynamic> json) {
  return _SalesReport.fromJson(json);
}

/// @nodoc
mixin _$SalesReport {
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get endDate => throw _privateConstructorUsedError;
  double get totalSales => throw _privateConstructorUsedError;
  double get totalProfit => throw _privateConstructorUsedError;
  int get totalTransactions => throw _privateConstructorUsedError;
  double get cashSales => throw _privateConstructorUsedError;
  double get creditSales => throw _privateConstructorUsedError;
  List<DailyStats> get dailyBreakdown => throw _privateConstructorUsedError;
  List<ProductStats> get topProducts => throw _privateConstructorUsedError;

  /// Serializes this SalesReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesReportCopyWith<SalesReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesReportCopyWith<$Res> {
  factory $SalesReportCopyWith(
    SalesReport value,
    $Res Function(SalesReport) then,
  ) = _$SalesReportCopyWithImpl<$Res, SalesReport>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime startDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime endDate,
    double totalSales,
    double totalProfit,
    int totalTransactions,
    double cashSales,
    double creditSales,
    List<DailyStats> dailyBreakdown,
    List<ProductStats> topProducts,
  });
}

/// @nodoc
class _$SalesReportCopyWithImpl<$Res, $Val extends SalesReport>
    implements $SalesReportCopyWith<$Res> {
  _$SalesReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? totalSales = null,
    Object? totalProfit = null,
    Object? totalTransactions = null,
    Object? cashSales = null,
    Object? creditSales = null,
    Object? dailyBreakdown = null,
    Object? topProducts = null,
  }) {
    return _then(
      _value.copyWith(
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalSales: null == totalSales
                ? _value.totalSales
                : totalSales // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProfit: null == totalProfit
                ? _value.totalProfit
                : totalProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            totalTransactions: null == totalTransactions
                ? _value.totalTransactions
                : totalTransactions // ignore: cast_nullable_to_non_nullable
                      as int,
            cashSales: null == cashSales
                ? _value.cashSales
                : cashSales // ignore: cast_nullable_to_non_nullable
                      as double,
            creditSales: null == creditSales
                ? _value.creditSales
                : creditSales // ignore: cast_nullable_to_non_nullable
                      as double,
            dailyBreakdown: null == dailyBreakdown
                ? _value.dailyBreakdown
                : dailyBreakdown // ignore: cast_nullable_to_non_nullable
                      as List<DailyStats>,
            topProducts: null == topProducts
                ? _value.topProducts
                : topProducts // ignore: cast_nullable_to_non_nullable
                      as List<ProductStats>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalesReportImplCopyWith<$Res>
    implements $SalesReportCopyWith<$Res> {
  factory _$$SalesReportImplCopyWith(
    _$SalesReportImpl value,
    $Res Function(_$SalesReportImpl) then,
  ) = __$$SalesReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime startDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime endDate,
    double totalSales,
    double totalProfit,
    int totalTransactions,
    double cashSales,
    double creditSales,
    List<DailyStats> dailyBreakdown,
    List<ProductStats> topProducts,
  });
}

/// @nodoc
class __$$SalesReportImplCopyWithImpl<$Res>
    extends _$SalesReportCopyWithImpl<$Res, _$SalesReportImpl>
    implements _$$SalesReportImplCopyWith<$Res> {
  __$$SalesReportImplCopyWithImpl(
    _$SalesReportImpl _value,
    $Res Function(_$SalesReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalesReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = null,
    Object? endDate = null,
    Object? totalSales = null,
    Object? totalProfit = null,
    Object? totalTransactions = null,
    Object? cashSales = null,
    Object? creditSales = null,
    Object? dailyBreakdown = null,
    Object? topProducts = null,
  }) {
    return _then(
      _$SalesReportImpl(
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalSales: null == totalSales
            ? _value.totalSales
            : totalSales // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProfit: null == totalProfit
            ? _value.totalProfit
            : totalProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        totalTransactions: null == totalTransactions
            ? _value.totalTransactions
            : totalTransactions // ignore: cast_nullable_to_non_nullable
                  as int,
        cashSales: null == cashSales
            ? _value.cashSales
            : cashSales // ignore: cast_nullable_to_non_nullable
                  as double,
        creditSales: null == creditSales
            ? _value.creditSales
            : creditSales // ignore: cast_nullable_to_non_nullable
                  as double,
        dailyBreakdown: null == dailyBreakdown
            ? _value._dailyBreakdown
            : dailyBreakdown // ignore: cast_nullable_to_non_nullable
                  as List<DailyStats>,
        topProducts: null == topProducts
            ? _value._topProducts
            : topProducts // ignore: cast_nullable_to_non_nullable
                  as List<ProductStats>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SalesReportImpl implements _SalesReport {
  const _$SalesReportImpl({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.startDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required this.endDate,
    required this.totalSales,
    required this.totalProfit,
    required this.totalTransactions,
    required this.cashSales,
    required this.creditSales,
    required final List<DailyStats> dailyBreakdown,
    required final List<ProductStats> topProducts,
  }) : _dailyBreakdown = dailyBreakdown,
       _topProducts = topProducts;

  factory _$SalesReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesReportImplFromJson(json);

  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime startDate;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime endDate;
  @override
  final double totalSales;
  @override
  final double totalProfit;
  @override
  final int totalTransactions;
  @override
  final double cashSales;
  @override
  final double creditSales;
  final List<DailyStats> _dailyBreakdown;
  @override
  List<DailyStats> get dailyBreakdown {
    if (_dailyBreakdown is EqualUnmodifiableListView) return _dailyBreakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyBreakdown);
  }

  final List<ProductStats> _topProducts;
  @override
  List<ProductStats> get topProducts {
    if (_topProducts is EqualUnmodifiableListView) return _topProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topProducts);
  }

  @override
  String toString() {
    return 'SalesReport(startDate: $startDate, endDate: $endDate, totalSales: $totalSales, totalProfit: $totalProfit, totalTransactions: $totalTransactions, cashSales: $cashSales, creditSales: $creditSales, dailyBreakdown: $dailyBreakdown, topProducts: $topProducts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesReportImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.totalProfit, totalProfit) ||
                other.totalProfit == totalProfit) &&
            (identical(other.totalTransactions, totalTransactions) ||
                other.totalTransactions == totalTransactions) &&
            (identical(other.cashSales, cashSales) ||
                other.cashSales == cashSales) &&
            (identical(other.creditSales, creditSales) ||
                other.creditSales == creditSales) &&
            const DeepCollectionEquality().equals(
              other._dailyBreakdown,
              _dailyBreakdown,
            ) &&
            const DeepCollectionEquality().equals(
              other._topProducts,
              _topProducts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    startDate,
    endDate,
    totalSales,
    totalProfit,
    totalTransactions,
    cashSales,
    creditSales,
    const DeepCollectionEquality().hash(_dailyBreakdown),
    const DeepCollectionEquality().hash(_topProducts),
  );

  /// Create a copy of SalesReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesReportImplCopyWith<_$SalesReportImpl> get copyWith =>
      __$$SalesReportImplCopyWithImpl<_$SalesReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesReportImplToJson(this);
  }
}

abstract class _SalesReport implements SalesReport {
  const factory _SalesReport({
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime startDate,
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    required final DateTime endDate,
    required final double totalSales,
    required final double totalProfit,
    required final int totalTransactions,
    required final double cashSales,
    required final double creditSales,
    required final List<DailyStats> dailyBreakdown,
    required final List<ProductStats> topProducts,
  }) = _$SalesReportImpl;

  factory _SalesReport.fromJson(Map<String, dynamic> json) =
      _$SalesReportImpl.fromJson;

  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get startDate;
  @override
  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  DateTime get endDate;
  @override
  double get totalSales;
  @override
  double get totalProfit;
  @override
  int get totalTransactions;
  @override
  double get cashSales;
  @override
  double get creditSales;
  @override
  List<DailyStats> get dailyBreakdown;
  @override
  List<ProductStats> get topProducts;

  /// Create a copy of SalesReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesReportImplCopyWith<_$SalesReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
