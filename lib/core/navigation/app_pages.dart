import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

// Auth screens
import 'package:kaskredit_1/features/auth/presentation/screens/splash_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/login_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/register_screen.dart';

// Dashboard
import 'package:kaskredit_1/features/dashboard/presentation/screens/dashboard_screen.dart';

// Products screens
import 'package:kaskredit_1/features/products/presentation/screens/product_list_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/add_product_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/edit_product_screen.dart';

// Customers screens
import 'package:kaskredit_1/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/edit_customer_screen.dart';

// Expenses screens
import 'package:kaskredit_1/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/edit_expense_screen.dart';

// Transactions screens (masih menggunakan old screens untuk sementara)
import 'package:kaskredit_1/features/transactions/presentation/screens/cashier_screen.dart';
// import 'package:kaskredit_1/features/transactions/presentation/screens/debt_screen.dart'; // COMMENTED: File tidak ada

// Reports screens (masih menggunakan old screens untuk sementara)
// import 'package:kaskredit_1/features/reports/presentation/screens/report_screen.dart'; // COMMENTED: File tidak ada
// import 'package:kaskredit_1/features/reports/presentation/screens/transaction_history_screen.dart'; // COMMENTED: File tidak ada
// import 'package:kaskredit_1/features/reports/presentation/screens/payment_history_screen.dart'; // COMMENTED: File tidak ada

// Settings screens (masih menggunakan old screens untuk sementara)
import 'package:kaskredit_1/features/settings/presentation/screens/settings_screen.dart';
// import 'package:kaskredit_1/features/settings/presentation/screens/printer_settings_screen.dart'; // COMMENTED: File tidak ada

class AppPages {
  static final routes = [
    // Auth routes
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
    ),

    // Dashboard
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardScreen(),
    ),

    // Product routes
    GetPage(
      name: AppRoutes.PRODUCTS,
      page: () => const ProductListScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_PRODUCT,
      page: () => const AddProductScreen(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PRODUCT,
      page: () => const EditProductScreen(), // Argument: Product
    ),

    // Customer routes
    GetPage(
      name: AppRoutes.CUSTOMERS,
      page: () => const CustomerListScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_CUSTOMER,
      page: () => const AddCustomerScreen(),
    ),
    GetPage(
      name: AppRoutes.EDIT_CUSTOMER,
      page: () => const EditCustomerScreen(), // Argument: Customer
    ),

    // Transaction routes (masih old)
    GetPage(
      name: AppRoutes.CASHIER,
      page: () => const CashierScreen(),
    ),
    // GetPage(
    //   name: AppRoutes.DEBT,
    //   page: () => const DebtScreen(), // COMMENTED: Screen tidak ada
    // ),

    // Expense routes
    GetPage(
      name: AppRoutes.EXPENSES,
      page: () => const ExpenseListScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_EXPENSE,
      page: () => const AddExpenseScreen(),
    ),
    GetPage(
      name: AppRoutes.EDIT_EXPENSE,
      page: () => const EditExpenseScreen(), // Argument: Expense
    ),

    // Report routes (masih old)
    // GetPage(
    //   name: AppRoutes.REPORTS,
    //   page: () => const ReportScreen(), // COMMENTED: Screen tidak ada
    // ),
    // GetPage(
    //   name: AppRoutes.HISTORY,
    //   page: () => const TransactionHistoryScreen(), // COMMENTED: Screen tidak ada
    // ),
    // GetPage(
    //   name: AppRoutes.PAYMENT_HISTORY,
    //   page: () => const PaymentHistoryScreen(), // COMMENTED: Screen tidak ada
    // ),

    // Settings routes (masih old)
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
    // GetPage(
    //   name: AppRoutes.PRINTER_SETTINGS,
    //   page: () => const PrinterSettingsScreen(), // COMMENTED: Screen tidak ada
    // ),
  ];
}
