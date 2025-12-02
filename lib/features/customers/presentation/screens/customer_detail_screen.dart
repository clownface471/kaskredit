import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart' hide Transaction;
import 'package:kaskredit_1/shared/models/transaction.dart' as tx;
import 'package:kaskredit_1/shared/models/payment.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:intl/intl.dart';

class CustomerDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Customer customer;
  
  final RxList<tx.Transaction> transactions = <tx.Transaction>[].obs;
  final RxList<Payment> payments = <Payment>[].obs;
  final RxBool isLoading = true.obs;
  
  // ✨ BARU: Statistik customer
  final RxInt totalTransactions = 0.obs;
  final RxDouble totalSpent = 0.0.obs;
  final RxDouble totalPaid = 0.0.obs;

  CustomerDetailController(this.customer);

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Load transactions
    _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('customerId', isEqualTo: customer.id)
        .orderBy('transactionDate', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      transactions.value = snapshot.docs
          .map((doc) => tx.Transaction.fromFirestore(doc))
          .toList();
      
      // ✨ BARU: Hitung statistik
      totalTransactions.value = transactions.length;
      totalSpent.value = transactions.fold(0.0, (sum, tx) => sum + tx.totalAmount);
    });

    // Load payments
    _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .where('customerId', isEqualTo: customer.id)
        .orderBy('paymentDate', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      payments.value = snapshot.docs
          .map((doc) => Payment.fromFirestore(doc))
          .toList();
      
      // ✨ BARU: Hitung total pembayaran
      totalPaid.value = payments.fold(0.0, (sum, p) => sum + p.paymentAmount);
      
      isLoading.value = false;
    });
  }

  // ✨ BARU: Fungsi untuk call customer
  void callCustomer() {
    if (customer.phoneNumber == null || customer.phoneNumber!.isEmpty) {
      Get.snackbar(
        'Info',
        'Nomor telepon tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // TODO: Implement actual phone call using url_launcher
    Get.snackbar(
      'Panggilan',
      'Fitur panggilan akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ✨ BARU: Fungsi untuk WhatsApp
  void sendWhatsApp() {
    if (customer.phoneNumber == null || customer.phoneNumber!.isEmpty) {
      Get.snackbar(
        'Info',
        'Nomor telepon tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // TODO: Implement WhatsApp using url_launcher
    Get.snackbar(
      'WhatsApp',
      'Fitur WhatsApp akan segera tersedia',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments as Customer;
    final controller = Get.put(CustomerDetailController(customer));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Detail Pelanggan"),
          actions: [
            // ✨ BARU: Tombol call & WhatsApp
            if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty) ...[
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: controller.callCustomer,
                tooltip: 'Telepon',
              ),
              IconButton(
                icon: const Icon(Icons.chat),
                onPressed: controller.sendWhatsApp,
                tooltip: 'WhatsApp',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.toNamed(
                AppRoutes.EDIT_CUSTOMER,
                arguments: customer,
              ),
              tooltip: 'Edit',
            ),
          ],
        ),
        body: Column(
          children: [
            // Customer Info Header
            _buildCustomerHeader(customer, controller),

            // Tab Bar
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: "Transaksi", icon: Icon(Icons.receipt_long, size: 20)),
                  Tab(text: "Pembayaran", icon: Icon(Icons.payment, size: 20)),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return TabBarView(
                  children: [
                    _buildTransactionsList(controller),
                    _buildPaymentsList(controller),
                  ],
                );
              }),
            ),
          ],
        ),
        floatingActionButton: customer.totalDebt > 0
            ? FloatingActionButton.extended(
                onPressed: () => Get.toNamed(AppRoutes.DEBT),
                icon: const Icon(Icons.monetization_on),
                label: const Text("Bayar Utang"),
                backgroundColor: Colors.orange,
              )
            : null,
      ),
    );
  }

  Widget _buildCustomerHeader(Customer customer, CustomerDetailController controller) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: customer.totalDebt > 0 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: customer.totalDebt > 0 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              customer.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (customer.phoneNumber != null && 
                customer.phoneNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    customer.phoneNumber!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            if (customer.address != null && customer.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      customer.address!,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            
            // ✨ BARU: Notes jika ada
            if (customer.notes != null && customer.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customer.notes!,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Divider(height: 24),
            
            // ✨ IMPROVED: Statistik lebih lengkap
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: "Total Utang",
                  value: Formatters.currency(customer.totalDebt),
                  valueColor: customer.totalDebt > 0 ? Colors.red : Colors.green,
                ),
                _StatColumn(
                  label: "Total Belanja",
                  value: Formatters.currency(controller.totalSpent.value),
                  valueColor: Colors.blue,
                ),
                _StatColumn(
                  label: "Transaksi",
                  value: "${controller.totalTransactions.value}x",
                  valueColor: Colors.grey[700],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(CustomerDetailController controller) {
    if (controller.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Belum ada transaksi",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.transactions.length,
      itemBuilder: (context, index) {
        final transaction = controller.transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(transaction.paymentStatus)
                  .withOpacity(0.1),
              child: Icon(
                _getStatusIcon(transaction.paymentStatus),
                color: _getStatusColor(transaction.paymentStatus),
              ),
            ),
            title: Text(
              transaction.transactionNumber,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM yyyy, HH:mm').format(transaction.transactionDate),
                ),
                // ✨ BARU: Tampilkan jumlah item
                Text(
                  "${transaction.items.length} item",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(transaction.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (transaction.remainingDebt > 0)
                  Text(
                    "Sisa: ${Formatters.currency(transaction.remainingDebt)}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to transaction detail
              Get.snackbar(
                'Info',
                'Detail transaksi: ${transaction.transactionNumber}',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList(CustomerDetailController controller) {
    if (controller.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Belum ada pembayaran",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ✨ BARU: Summary pembayaran
        Obx(() => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Dibayar',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.currency(controller.totalPaid.value),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        )),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.payments.length,
            itemBuilder: (context, index) {
              final payment = controller.payments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    Formatters.currency(payment.paymentAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM yyyy, HH:mm')
                            .format(payment.paymentDate),
                      ),
                      Text(
                        "Ref: ${payment.transactionId.substring(0, 8)}...",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: payment.remainingDebt > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Sisa',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            Text(
                              Formatters.currency(payment.remainingDebt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(tx.PaymentStatus status) {
    switch (status) {
      case tx.PaymentStatus.PAID:
        return Colors.green;
      case tx.PaymentStatus.PARTIAL:
        return Colors.orange;
      case tx.PaymentStatus.DEBT:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(tx.PaymentStatus status) {
    switch (status) {
      case tx.PaymentStatus.PAID:
        return Icons.check_circle;
      case tx.PaymentStatus.PARTIAL:
        return Icons.hourglass_top;
      case tx.PaymentStatus.DEBT:
        return Icons.error;
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}