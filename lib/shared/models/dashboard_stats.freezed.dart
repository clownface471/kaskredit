// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  // Statistik hari ini
  double get todaySales => throw _privateConstructorUsedError;
  double get todayProfit => throw _privateConstructorUsedError;
  int get todayTransactions => throw _privateConstructorUsedError;
  double get todayNewDebt =>
      throw _privateConstructorUsedError; // Statistik keseluruhan
  double get totalOutstandingDebt => throw _privateConstructorUsedError;
  int get totalDebtors =>
      throw _privateConstructorUsedError; // Jumlah pelanggan yg punya utang
  // Statistik inventaris
  int get lowStockProducts => throw _privateConstructorUsedError;

  /// Serializes this DashboardStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
    DashboardStats value,
    $Res Function(DashboardStats) then,
  ) = _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call({
    double todaySales,
    double todayProfit,
    int todayTransactions,
    double todayNewDebt,
    double totalOutstandingDebt,
    int totalDebtors,
    int lowStockProducts,
  });
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todaySales = null,
    Object? todayProfit = null,
    Object? todayTransactions = null,
    Object? todayNewDebt = null,
    Object? totalOutstandingDebt = null,
    Object? totalDebtors = null,
    Object? lowStockProducts = null,
  }) {
    return _then(
      _value.copyWith(
            todaySales: null == todaySales
                ? _value.todaySales
                : todaySales // ignore: cast_nullable_to_non_nullable
                      as double,
            todayProfit: null == todayProfit
                ? _value.todayProfit
                : todayProfit // ignore: cast_nullable_to_non_nullable
                      as double,
            todayTransactions: null == todayTransactions
                ? _value.todayTransactions
                : todayTransactions // ignore: cast_nullable_to_non_nullable
                      as int,
            todayNewDebt: null == todayNewDebt
                ? _value.todayNewDebt
                : todayNewDebt // ignore: cast_nullable_to_non_nullable
                      as double,
            totalOutstandingDebt: null == totalOutstandingDebt
                ? _value.totalOutstandingDebt
                : totalOutstandingDebt // ignore: cast_nullable_to_non_nullable
                      as double,
            totalDebtors: null == totalDebtors
                ? _value.totalDebtors
                : totalDebtors // ignore: cast_nullable_to_non_nullable
                      as int,
            lowStockProducts: null == lowStockProducts
                ? _value.lowStockProducts
                : lowStockProducts // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(
    _$DashboardStatsImpl value,
    $Res Function(_$DashboardStatsImpl) then,
  ) = __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double todaySales,
    double todayProfit,
    int todayTransactions,
    double todayNewDebt,
    double totalOutstandingDebt,
    int totalDebtors,
    int lowStockProducts,
  });
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
    _$DashboardStatsImpl _value,
    $Res Function(_$DashboardStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todaySales = null,
    Object? todayProfit = null,
    Object? todayTransactions = null,
    Object? todayNewDebt = null,
    Object? totalOutstandingDebt = null,
    Object? totalDebtors = null,
    Object? lowStockProducts = null,
  }) {
    return _then(
      _$DashboardStatsImpl(
        todaySales: null == todaySales
            ? _value.todaySales
            : todaySales // ignore: cast_nullable_to_non_nullable
                  as double,
        todayProfit: null == todayProfit
            ? _value.todayProfit
            : todayProfit // ignore: cast_nullable_to_non_nullable
                  as double,
        todayTransactions: null == todayTransactions
            ? _value.todayTransactions
            : todayTransactions // ignore: cast_nullable_to_non_nullable
                  as int,
        todayNewDebt: null == todayNewDebt
            ? _value.todayNewDebt
            : todayNewDebt // ignore: cast_nullable_to_non_nullable
                  as double,
        totalOutstandingDebt: null == totalOutstandingDebt
            ? _value.totalOutstandingDebt
            : totalOutstandingDebt // ignore: cast_nullable_to_non_nullable
                  as double,
        totalDebtors: null == totalDebtors
            ? _value.totalDebtors
            : totalDebtors // ignore: cast_nullable_to_non_nullable
                  as int,
        lowStockProducts: null == lowStockProducts
            ? _value.lowStockProducts
            : lowStockProducts // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl({
    required this.todaySales,
    required this.todayProfit,
    required this.todayTransactions,
    required this.todayNewDebt,
    required this.totalOutstandingDebt,
    required this.totalDebtors,
    required this.lowStockProducts,
  });

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  // Statistik hari ini
  @override
  final double todaySales;
  @override
  final double todayProfit;
  @override
  final int todayTransactions;
  @override
  final double todayNewDebt;
  // Statistik keseluruhan
  @override
  final double totalOutstandingDebt;
  @override
  final int totalDebtors;
  // Jumlah pelanggan yg punya utang
  // Statistik inventaris
  @override
  final int lowStockProducts;

  @override
  String toString() {
    return 'DashboardStats(todaySales: $todaySales, todayProfit: $todayProfit, todayTransactions: $todayTransactions, todayNewDebt: $todayNewDebt, totalOutstandingDebt: $totalOutstandingDebt, totalDebtors: $totalDebtors, lowStockProducts: $lowStockProducts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.todaySales, todaySales) ||
                other.todaySales == todaySales) &&
            (identical(other.todayProfit, todayProfit) ||
                other.todayProfit == todayProfit) &&
            (identical(other.todayTransactions, todayTransactions) ||
                other.todayTransactions == todayTransactions) &&
            (identical(other.todayNewDebt, todayNewDebt) ||
                other.todayNewDebt == todayNewDebt) &&
            (identical(other.totalOutstandingDebt, totalOutstandingDebt) ||
                other.totalOutstandingDebt == totalOutstandingDebt) &&
            (identical(other.totalDebtors, totalDebtors) ||
                other.totalDebtors == totalDebtors) &&
            (identical(other.lowStockProducts, lowStockProducts) ||
                other.lowStockProducts == lowStockProducts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    todaySales,
    todayProfit,
    todayTransactions,
    todayNewDebt,
    totalOutstandingDebt,
    totalDebtors,
    lowStockProducts,
  );

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(this);
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats({
    required final double todaySales,
    required final double todayProfit,
    required final int todayTransactions,
    required final double todayNewDebt,
    required final double totalOutstandingDebt,
    required final int totalDebtors,
    required final int lowStockProducts,
  }) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  // Statistik hari ini
  @override
  double get todaySales;
  @override
  double get todayProfit;
  @override
  int get todayTransactions;
  @override
  double get todayNewDebt; // Statistik keseluruhan
  @override
  double get totalOutstandingDebt;
  @override
  int get totalDebtors; // Jumlah pelanggan yg punya utang
  // Statistik inventaris
  @override
  int get lowStockProducts;

  /// Create a copy of DashboardStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
