abstract class AppRoutes {
  // Authentication
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const SPLASH = '/splash';
  
  // Main / Dashboard
  static const HOME = '/home';
  static const DASHBOARD = '/dashboard'; // Alias untuk Home
  
  // Cashier
  static const CASHIER = '/cashier';
  
  // Products
  static const PRODUCTS = '/products';
  static const ADD_PRODUCT = '/products/add';
  static const EDIT_PRODUCT = '/products/edit';
  static const PRODUCT_DETAIL = '/products/detail';
  
  // Customers
  static const CUSTOMERS = '/customers';
  static const ADD_CUSTOMER = '/customers/add';
  static const EDIT_CUSTOMER = '/customers/edit';
  static const CUSTOMER_DETAIL = '/customers/detail';
  
  // Transactions
  static const TRANSACTIONS = '/transactions';
  static const HISTORY = '/transactions'; // Alias untuk TRANSACTIONS (dipakai di Dashboard)
  static const TRANSACTION_DETAIL = '/transactions/detail';
  
  // Payments & Debt
  static const DEBT = '/debt';
  static const PAYMENT_HISTORY = '/payments/history';
  
  // Expenses (Pengeluaran) - Penambahan Baru
  static const EXPENSES = '/expenses';
  static const ADD_EXPENSE = '/expenses/add'; // Sesuaikan nama konstanta jika perlu (misal EXPENSE_ADD)
  static const EDIT_EXPENSE = '/expenses/edit'; // Sesuaikan nama konstanta jika perlu
  
  // Reports
  static const REPORTS = '/reports';
  
  // Settings
  static const SETTINGS = '/settings';
  
  // Printer
  static const BLUETOOTH_PRINTER = '/bluetooth-printer';
  static const PRINTER_SETTINGS = '/printer-settings';
  static const PRINTER_SELECTION = '/printer-selection';
}