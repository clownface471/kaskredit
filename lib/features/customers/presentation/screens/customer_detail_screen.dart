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
  final RxInt selectedTab = 0.obs;

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
      isLoading.value = false;
    });
  }
}

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Customer customer = Get.arguments as Customer;
    final controller = Get.put(CustomerDetailController(customer));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pelanggan"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.toNamed(
              AppRoutes.EDIT_CUSTOMER,
              arguments: customer,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Info Header
          _buildCustomerHeader(customer),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: TabController(length: 2, vsync: Navigator.of(context)),
              onTap: (index) => controller.selectedTab.value = index,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
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
                controller: TabController(length: 2, vsync: Navigator.of(context)),
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
    );
  }

  Widget _buildCustomerHeader(Customer customer) {
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
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  label: "Total Utang",
                  value: Formatters.currency(customer.totalDebt),
                  valueColor: customer.totalDebt > 0 ? Colors.red : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(CustomerDetailController controller) {
    if (controller.transactions.isEmpty) {
      return const Center(
        child: Text("Belum ada transaksi"),
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
            subtitle: Text(
              DateFormat('d MMM yyyy').format(transaction.transactionDate),
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
            onTap: () => Get.toNamed(
              AppRoutes.TRANSACTION_DETAIL,
              arguments: transaction,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsList(CustomerDetailController controller) {
    if (controller.payments.isEmpty) {
      return const Center(
        child: Text("Belum ada pembayaran"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
              "Pembayaran ${Formatters.currency(payment.paymentAmount)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMM yyyy, HH:mm')
                      .format(payment.paymentDate),
                ),
                Text(
                  "Ref: ${payment.transactionId.substring(0, 8)}...",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: payment.remainingDebt > 0
                ? Text(
                    "Sisa: ${Formatters.currency(payment.remainingDebt)}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                    ),
                  )
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        );
      },
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PAID:
        return Colors.green;
      case PaymentStatus.PARTIAL:
        return Colors.orange;
      case PaymentStatus.DEBT:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.PAID:
        return Icons.check_circle;
      case PaymentStatus.PARTIAL:
        return Icons.hourglass_top;
      case PaymentStatus.DEBT:
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}