import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

// Auth
import 'package:kaskredit_1/features/auth/presentation/screens/login_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/register_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/splash_screen.dart';

// Dashboard (Pengganti Home)
import 'package:kaskredit_1/features/dashboard/presentation/screens/dashboard_screen.dart';

// Products
import 'package:kaskredit_1/features/products/presentation/screens/product_list_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/add_product_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/edit_product_screen.dart';
// Note: Product Detail Screen file belum ada, route dikomentari dulu

// Customers
import 'package:kaskredit_1/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/edit_customer_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/customer_detail_screen.dart';

// Transactions
import 'package:kaskredit_1/features/transactions/presentation/screens/cashier_screen.dart';
import 'package:kaskredit_1/features/transactions/presentation/screens/transaction_history_screen.dart';
import 'package:kaskredit_1/features/transactions/presentation/screens/transaction_detail_screen.dart';

// Payments
import 'package:kaskredit_1/features/payments/presentation/screens/debt_management_screen.dart';
import 'package:kaskredit_1/features/payments/presentation/screens/payment_history_screen.dart';

// Expenses (Pengeluaran - Tambahan agar menu dashboard jalan)
import 'package:kaskredit_1/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/edit_expense_screen.dart';

// Reports
import 'package:kaskredit_1/features/reports/presentation/screens/report_screen.dart';

// Settings
import 'package:kaskredit_1/features/settings/presentation/screens/settings_screen.dart';

// Printer
import 'package:kaskredit_1/features/printer/presentation/screens/bluetooth_printer_screen.dart';

class AppPages {
  static final routes = [
    // Auth
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
    ),
    
    // Home / Dashboard
    GetPage(
      name: AppRoutes.HOME, // Diarahkan ke DashboardScreen
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: '/dashboard', // Alias jika diperlukan
      page: () => const DashboardScreen(),
    ),
    
    // Cashier
    GetPage(
      name: AppRoutes.CASHIER,
      page: () => const CashierScreen(),
    ),
    
    // Products
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
      page: () => const EditProductScreen(),
    ),
    // Route Detail Produk dikomentari karena file belum ada
    // GetPage(
    //   name: AppRoutes.PRODUCT_DETAIL,
    //   page: () => const ProductDetailScreen(),
    // ),
    
    // Customers
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
      page: () => const EditCustomerScreen(),
    ),
    GetPage(
      name: AppRoutes.CUSTOMER_DETAIL,
      page: () => const CustomerDetailScreen(),
    ),
    
    // Transactions
    GetPage(
      name: AppRoutes.TRANSACTIONS,
      page: () => const TransactionHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.TRANSACTION_DETAIL,
      page: () => const TransactionDetailScreen(),
    ),
    
    // Payments & Debt
    GetPage(
      name: AppRoutes.DEBT,
      page: () => const DebtManagementScreen(),
    ),
    GetPage(
      name: AppRoutes.PAYMENT_HISTORY,
      page: () => const PaymentHistoryScreen(),
    ),

    // Expenses (Tambahkan route constant di AppRoutes jika belum ada)
    GetPage(
      name: '/expenses', // Pastikan AppRoutes.EXPENSES ada, atau pakai string ini
      page: () => const ExpenseListScreen(),
    ),
    GetPage(
      name: '/expenses/add',
      page: () => const AddExpenseScreen(),
    ),
    GetPage(
      name: '/expenses/edit',
      page: () => const EditExpenseScreen(),
    ),
    
    // Reports
    GetPage(
      name: AppRoutes.REPORTS,
      page: () => const ReportScreen(),
    ),
    
    // Settings
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
    
    // Bluetooth Printer
    GetPage(
      name: AppRoutes.BLUETOOTH_PRINTER,
      page: () => const BluetoothPrinterScreen(),
    ),
    GetPage(
      name: AppRoutes.PRINTER_SELECTION,
      page: () => const BluetoothPrinterScreen(),
    ),
  ];
}