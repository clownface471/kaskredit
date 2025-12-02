import 'package:get/get.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';

// Screens
import 'package:kaskredit_1/features/auth/presentation/screens/splash_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/login_screen.dart';
import 'package:kaskredit_1/features/auth/presentation/screens/register_screen.dart';
import 'package:kaskredit_1/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/product_list_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/add_product_screen.dart';
import 'package:kaskredit_1/features/products/presentation/screens/edit_product_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/edit_customer_screen.dart';
import 'package:kaskredit_1/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:kaskredit_1/features/expenses/presentation/screens/edit_expense_screen.dart';
import 'package:kaskredit_1/features/transactions/presentation/screens/cashier_screen.dart';
import 'package:kaskredit_1/features/transactions/presentation/screens/transaction_history_screen.dart';
import 'package:kaskredit_1/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:kaskredit_1/features/payments/presentation/screens/payment_history_screen.dart';
import 'package:kaskredit_1/features/payments/presentation/screens/debt_management_screen.dart';
import 'package:kaskredit_1/features/settings/presentation/screens/settings_screen.dart';
import 'package:kaskredit_1/features/printer/presentation/screens/printer_settings_screen.dart';
import 'package:kaskredit_1/features/reports/presentation/screens/report_screen.dart'; 


class AppPages {
  static final routes = [
    // Auth
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.LOGIN, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.REGISTER, page: () => const RegisterScreen()),
    
    // Dashboard
    GetPage(name: AppRoutes.DASHBOARD, page: () => const DashboardScreen()),
    
    // Products
    GetPage(name: AppRoutes.PRODUCTS, page: () => const ProductListScreen()),
    GetPage(name: AppRoutes.ADD_PRODUCT, page: () => const AddProductScreen()),
    GetPage(name: AppRoutes.EDIT_PRODUCT, page: () => const EditProductScreen()),

    // Customers
    GetPage(name: AppRoutes.CUSTOMERS, page: () => const CustomerListScreen()),
    GetPage(name: AppRoutes.ADD_CUSTOMER, page: () => const AddCustomerScreen()),
    GetPage(name: AppRoutes.EDIT_CUSTOMER, page: () => const EditCustomerScreen()),
    GetPage(name: AppRoutes.CUSTOMER_DETAIL, page: () => const CustomerDetailScreen()), // NEW

    // Transactions
    GetPage(name: AppRoutes.CASHIER, page: () => const CashierScreen()),
    GetPage(name: AppRoutes.HISTORY, page: () => const TransactionHistoryScreen()),
    GetPage(name: AppRoutes.TRANSACTION_DETAIL, page: () => const TransactionDetailScreen()), // NEW
    
    // Payments & Debt
    GetPage(name: AppRoutes.DEBT, page: () => const DebtManagementScreen()),
    GetPage(name: AppRoutes.PAYMENT_HISTORY, page: () => const PaymentHistoryScreen()),

    // Expenses
    GetPage(name: AppRoutes.EXPENSES, page: () => const ExpenseListScreen()),
    GetPage(name: AppRoutes.ADD_EXPENSE, page: () => const AddExpenseScreen()),
    GetPage(name: AppRoutes.EDIT_EXPENSE, page: () => const EditExpenseScreen()),

    // Settings
    GetPage(name: AppRoutes.SETTINGS, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.PRINTER_SETTINGS, page: () => const PrinterSettingsScreen()),

    // Reports
    GetPage(name: AppRoutes.REPORTS, page: () => const ReportScreen()), 
  ];
}