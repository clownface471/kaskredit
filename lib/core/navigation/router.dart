import 'package:go_router/go_router.dart';
// Hapus semua import GlobalKey dan MainShell
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../features/products/presentation/screens/edit_product_screen.dart';
import '../../features/products/presentation/providers/product_providers.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/customers/presentation/screens/add_customer_screen.dart';
import '../../features/customers/presentation/screens/edit_customer_screen.dart';
import '../../features/customers/presentation/providers/customer_providers.dart';
import '../../features/transactions/presentation/screens/cashier_screen.dart';
import '../../features/payments/presentation/screens/debt_management_screen.dart';
import '../../features/reports/presentation/screens/report_screen.dart';
import '../../shared/models/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../shared/models/product.dart';
import '../../features/transactions/presentation/screens/transaction_history_screen.dart';
import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/expenses/presentation/screens/edit_expense_screen.dart';
import '../../features/expenses/presentation/providers/expense_providers.dart';
import '../../shared/models/expense.dart';
import '../../features/payments/presentation/screens/payment_history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    // Ini Rute Dashboard kita (halaman tunggal)
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Halaman Produk (halaman terpisah)
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductScreen(),
        ),
        // 4. TAMBAHKAN RUTE EDIT DINAMIS
        GoRoute(
          path: 'edit/:id', // ':id' adalah parameter
          builder: (context, state) {
            // Ambil ID dari parameter URL
            final productId = state.pathParameters['id']!;

            // Kita butuh ProviderScope untuk 'read' provider di dalam builder
            return ProviderScope(
              child: Consumer(
                // Consumer agar kita bisa 'read'
                builder: (context, ref, child) {
                  // Ambil data produk dari provider list
                  final productAsync = ref.read(productsProvider);

                  // Cari produk spesifik berdasarkan ID
                  Product? product; // Deklarasikan sebagai nullable
                  try {
                    // Coba cari produknya
                    product = productAsync.valueOrNull?.firstWhere(
                      (p) => p.id == productId,
                      // Hapus 'orElse'
                    );
                  } catch (e) {
                    // Jika firstWhere gagal (StateError), set produk ke null
                    product = null;
                  }

                  if (product == null) {
                    return const Scaffold(
                      body: Center(child: Text("Produk tidak ditemukan")),
                    );
                  }

                  // Kirim produk yang ditemukan ke EditScreen
                  return EditProductScreen(product: product);
                },
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomerListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddCustomerScreen(),
        ),
        // RUTE BARU: EDIT CUSTOMER
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final customerId = state.pathParameters['id']!;
            return ProviderScope(
              child: Consumer(
                builder: (context, ref, child) {
                  // Pakai READ, bukan WATCH (agar tidak crash saat delete)
                  final customersAsync = ref.read(customersProvider);
                  Customer? customer;
                  try {
                    customer = customersAsync.valueOrNull?.firstWhere(
                      (c) => c.id == customerId,
                    );
                  } catch (_) {
                    customer = null;
                  }

                  if (customer == null) {
                    return const Scaffold(
                      body: Center(child: Text("Pelanggan tidak ditemukan")),
                    );
                  }
                  return EditCustomerScreen(customer: customer);
                },
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/debt',
      builder: (context, state) => const DebtManagementScreen(),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const ExpenseListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddExpenseScreen(),
        ),
        // --- TAMBAHKAN RUTE EDIT INI ---
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final expenseId = state.pathParameters['id']!;
            return ProviderScope(
              child: Consumer(
                builder: (context, ref, child) {
                  // Kita pakai .read agar tidak crash saat delete
                  final expensesAsync = ref.read(expensesProvider);
                  Expense? expense;
                  try {
                    expense = expensesAsync.valueOrNull?.firstWhere(
                      (e) => e.id == expenseId,
                    );
                  } catch (_) {
                    expense = null;
                  }

                  if (expense == null) {
                    return const Scaffold(
                      body: Center(child: Text("Pengeluaran tidak ditemukan")),
                    );
                  }
                  return EditExpenseScreen(expense: expense);
                },
              ),
            );
          },
        ),
        // --- AKHIR TAMBAHAN ---
      ],
    ),
    // Halaman Laporan (placeholder)
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/cashier',
      builder: (context, state) => const CashierScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const TransactionHistoryScreen(),
    ),
    GoRoute(
      path: '/payment-history',
      builder: (context, state) => const PaymentHistoryScreen(),
    ),
  ],
);
