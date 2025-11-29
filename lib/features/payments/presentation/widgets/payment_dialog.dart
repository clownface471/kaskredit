import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';
import 'package:kaskredit_1/core/utils/getx_utils.dart';
import 'package:kaskredit_1/core/utils/formatters.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentDialog extends StatefulWidget {
  final Customer customer;
  const PaymentDialog({super.key, required this.customer});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _amountController = TextEditingController();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  
  // Ubah state: Simpan ID-nya saja, bukan objeknya
  String? _selectedTransactionId;
  
  List<Transaction> _debtTransactions = [];
  bool _isLoading = false;
  bool _isFetchingTxs = true;

  @override
  void initState() {
    super.initState();
    _loadDebtTransactions();
  }

  void _loadDebtTransactions() {
    // Listen ke stream
    _transactionRepo.getTransactionsWithDebt(widget.customer.id!).listen((txs) {
      if (mounted) {
        setState(() {
          _debtTransactions = txs;
          _isFetchingTxs = false;
          
          // Validasi: Jika transaksi yang dipilih sebelumnya sudah tidak ada di list (misal lunas), reset
          if (_selectedTransactionId != null) {
            final exists = txs.any((t) => t.id == _selectedTransactionId);
            if (!exists) {
              _selectedTransactionId = null;
              _amountController.clear();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final paymentAmount = double.tryParse(_amountController.text) ?? 0;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (paymentAmount <= 0 || _selectedTransactionId == null || userId == null) {
      GetXUtils.showError("Data pembayaran tidak valid.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _paymentRepo.processPayment(
        transactionId: _selectedTransactionId!,
        customerId: widget.customer.id!,
        paymentAmount: paymentAmount,
        paymentMethod: "CASH",
        userId: userId,
        customerName: widget.customer.name,
      );
      
      if (mounted) {
        Get.back(); // Tutup dialog
        GetXUtils.showSuccess("Pembayaran berhasil!");
      }
    } catch (e) {
      GetXUtils.showError("Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cari objek transaksi berdasarkan ID yang dipilih untuk mendapatkan sisa utang
    final selectedTx = _debtTransactions.firstWhereOrNull((t) => t.id == _selectedTransactionId);
    final remainingDebt = selectedTx?.remainingDebt ?? 0;
    
    final canSubmit = _selectedTransactionId != null && !_isLoading;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bayar Utang: ${widget.customer.name}", style: Theme.of(context).textTheme.headlineSmall),
          Text("Total Utang Customer: ${Formatters.currency.format(widget.customer.totalDebt)}", 
               style: const TextStyle(color: Colors.red)),
          const Divider(height: 24),
          
          // 1. Pilih Transaksi Dropdown
          if (_isFetchingTxs)
            const LinearProgressIndicator()
          else if (_debtTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text("Tidak ada transaksi utang aktif."),
            )
          else
            DropdownButtonFormField<String>( // Tipe data sekarang String
              value: _selectedTransactionId,
              isExpanded: true,
              hint: const Text("Pilih Transaksi... (Wajib)"),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _debtTransactions.map((tx) {
                return DropdownMenuItem<String>(
                  value: tx.id, // Value adalah ID (String)
                  child: Text(
                    "${tx.transactionNumber} (Sisa: ${Formatters.currency.format(tx.remainingDebt)})",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTransactionId = val;
                  // Auto-fill jumlah bayar dengan sisa utang transaksi tersebut
                  final tx = _debtTransactions.firstWhereOrNull((t) => t.id == val);
                  if (tx != null) {
                    _amountController.text = tx.remainingDebt.toStringAsFixed(0);
                  }
                });
              },
            ),
          const SizedBox(height: 16),

          // 2. Masukkan Jumlah Bayar
          TextFormField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: "Jumlah Bayar (Maks: ${Formatters.currency.format(remainingDebt)})",
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 24),

          // 3. Tombol Konfirmasi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: canSubmit ? _processPayment : null, 
                    child: const Text("Konfirmasi Pembayaran"),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}