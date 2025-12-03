import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';
import 'package:kaskredit_1/shared/utils/formatters.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentDialogController extends GetxController {
  final Customer customer;
  final TransactionRepository _transactionRepo = TransactionRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  
  final RxList<Transaction> debtTransactions = <Transaction>[].obs;
  final Rxn<String> selectedTransactionId = Rxn<String>();
  final RxBool isLoading = false.obs;
  final RxBool isFetchingTransactions = true.obs;
  final RxString selectedPaymentMethod = 'CASH'.obs;
  
  PaymentDialogController(this.customer);
  
  @override
  void onInit() {
    super.onInit();
    _loadDebtTransactions();
  }
  
  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
  
  void _loadDebtTransactions() {
    _transactionRepo.getTransactionsWithDebt(customer.id!).listen((txs) {
      debtTransactions.value = txs;
      isFetchingTransactions.value = false;
      
      // Validasi transaksi terpilih masih ada
      if (selectedTransactionId.value != null) {
        final exists = txs.any((t) => t.id == selectedTransactionId.value);
        if (!exists) {
          selectedTransactionId.value = null;
          amountController.clear();
        }
      }
    });
  }
  
  Transaction? get selectedTransaction {
    if (selectedTransactionId.value == null) return null;
    return debtTransactions.firstWhereOrNull(
      (t) => t.id == selectedTransactionId.value
    );
  }
  
  double get remainingDebt => selectedTransaction?.remainingDebt ?? 0;
  double get paymentAmount => double.tryParse(amountController.text) ?? 0;
  double get newRemainingDebt => (remainingDebt - paymentAmount).clamp(0, double.infinity);
  bool get willBePaidOff => newRemainingDebt == 0;
  
  String? validatePaymentAmount() {
    if (selectedTransactionId.value == null) {
      return 'Pilih transaksi terlebih dahulu';
    }
    
    if (paymentAmount <= 0) {
      return 'Jumlah bayar harus lebih dari 0';
    }
    
    if (paymentAmount > remainingDebt + 1) {
      return 'Jumlah bayar melebihi sisa utang';
    }
    
    return null;
  }
  
  Future<void> processPayment() async {
    final validation = validatePaymentAmount();
    if (validation != null) {
      GetXUtils.showError(validation);
      return;
    }
    
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      GetXUtils.showError('User tidak login');
      return;
    }
    
    // Show confirmation
    final confirmed = await GetXUtils.showConfirmDialog(
      title: 'Konfirmasi Pembayaran',
      message: willBePaidOff
          ? 'Transaksi akan LUNAS setelah pembayaran ini. Lanjutkan?'
          : 'Proses pembayaran ${Formatters.currency(paymentAmount)}?',
      confirmText: 'Ya, Proses',
      cancelText: 'Batal',
      confirmColor: Colors.green,
    );
    
    if (!confirmed) return;
    
    isLoading.value = true;
    
    try {
      await _paymentRepo.processPayment(
        transactionId: selectedTransactionId.value!,
        customerId: customer.id!,
        paymentAmount: paymentAmount,
        paymentMethod: selectedPaymentMethod.value,
        userId: userId,
        customerName: customer.name,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
      );
      
      Get.back(); // Close dialog
      GetXUtils.showSuccess(
        willBePaidOff 
            ? 'Pembayaran berhasil! Transaksi sudah LUNAS.' 
            : 'Pembayaran berhasil diproses',
      );
    } catch (e) {
      GetXUtils.showError('Gagal: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void selectTransaction(String? transactionId) {
    selectedTransactionId.value = transactionId;
    
    if (transactionId != null) {
      final tx = debtTransactions.firstWhereOrNull((t) => t.id == transactionId);
      if (tx != null) {
        // Auto-fill dengan sisa utang
        amountController.text = tx.remainingDebt.toStringAsFixed(0);
      }
    } else {
      amountController.clear();
    }
  }
  
  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }
}

class PaymentDialog extends StatelessWidget {
  final Customer customer;
  
  const PaymentDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentDialogController(customer));
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bayar Utang",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Total Debt Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Utang Customer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        Formatters.currency(customer.totalDebt),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 32),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Select Transaction
                  const Text(
                    '1. Pilih Transaksi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Obx(() {
                    if (controller.isFetchingTransactions.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    if (controller.debtTransactions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Tidak ada transaksi utang aktif."),
                      );
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: controller.selectedTransactionId.value,
                      isExpanded: true,
                      hint: const Text("Pilih Transaksi... (Wajib)"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: controller.debtTransactions.map((tx) {
                        return DropdownMenuItem<String>(
                          value: tx.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tx.transactionNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Sisa: ${Formatters.currency(tx.remainingDebt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: controller.selectTransaction,
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  // 2. Payment Amount
                  const Text(
                    '2. Jumlah Bayar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Obx(() {
                    return TextFormField(
                      controller: controller.amountController,
                      decoration: InputDecoration(
                        labelText: controller.selectedTransaction != null
                            ? "Maksimal: ${Formatters.currency(controller.remainingDebt)}"
                            : "Jumlah Bayar",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixIcon: controller.selectedTransaction != null
                            ? IconButton(
                                icon: const Icon(Icons.check_circle),
                                color: Colors.green,
                                tooltip: 'Bayar Penuh',
                                onPressed: () {
                                  controller.amountController.text =
                                      controller.remainingDebt.toStringAsFixed(0);
                                },
                              )
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: controller.selectedTransaction != null,
                      onChanged: (value) {
                        // Trigger rebuild untuk preview
                        controller.update();
                      },
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // 3. Payment Method
                  const Text(
                    '3. Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Obx(() {
                    return Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Tunai'),
                          selected: controller.selectedPaymentMethod.value == 'CASH',
                          onSelected: (_) => controller.setPaymentMethod('CASH'),
                          avatar: const Icon(Icons.payments, size: 18),
                        ),
                        ChoiceChip(
                          label: const Text('Transfer'),
                          selected: controller.selectedPaymentMethod.value == 'TRANSFER',
                          onSelected: (_) => controller.setPaymentMethod('TRANSFER'),
                          avatar: const Icon(Icons.account_balance, size: 18),
                        ),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 16),
                  
                  // 4. Notes (Optional)
                  const Text(
                    '4. Catatan (Opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  TextFormField(
                    controller: controller.notesController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Bayar cicilan ke-1",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Preview Calculation
                  Obx(() {
                    if (controller.selectedTransaction == null ||
                        controller.paymentAmount == 0) {
                      return const SizedBox.shrink();
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: controller.willBePaidOff
                            ? Colors.green.withOpacity(0.05)
                            : Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.willBePaidOff
                              ? Colors.green.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                controller.willBePaidOff
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: controller.willBePaidOff
                                    ? Colors.green
                                    : Colors.blue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Preview Pembayaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: controller.willBePaidOff
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _PreviewRow(
                            label: 'Utang Sebelumnya',
                            value: Formatters.currency(controller.remainingDebt),
                          ),
                          _PreviewRow(
                            label: 'Jumlah Bayar',
                            value: Formatters.currency(controller.paymentAmount),
                            valueColor: Colors.green,
                          ),
                          const Divider(height: 16),
                          _PreviewRow(
                            label: 'Sisa Utang',
                            value: Formatters.currency(controller.newRemainingDebt),
                            isBold: true,
                            valueColor: controller.willBePaidOff
                                ? Colors.green
                                : Colors.orange,
                          ),
                          if (controller.willBePaidOff) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.celebration,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Transaksi akan LUNAS!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Submit Button
          Obx(() {
            final canSubmit = controller.selectedTransaction != null &&
                !controller.isLoading.value;
            
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: canSubmit ? controller.processPayment : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        "Konfirmasi Pembayaran",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            );
          }),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}