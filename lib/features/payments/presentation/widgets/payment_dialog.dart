import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

// 1. Ubah jadi ConsumerStatefulWidget
class PaymentDialog extends ConsumerStatefulWidget {
  final Customer customer;
  const PaymentDialog({super.key, required this.customer});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  // State untuk melacak transaksi & jumlah bayar
  Transaction? _selectedTransaction;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // --- FUNGSI PROSES BAYAR ---
  Future<void> _processPayment() async {
    final paymentAmount = double.tryParse(_amountController.text) ?? 0;
    final userId = ref.read(currentUserProvider).value?.id;

    // Validasi
    if (paymentAmount <= 0 || _selectedTransaction == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data tidak valid.")),
      );
      return;
    }

    try {
      // Panggil repository
      await ref.read(paymentRepositoryProvider).processPayment(
            transactionId: _selectedTransaction!.id!,
            customerId: widget.customer.id!,
            paymentAmount: paymentAmount,
            paymentMethod: "CASH", // Asumsi bayar tunai
            userId: userId,
            customerName: widget.customer.name,
          );
      
      if (mounted) {
        Navigator.of(context).pop(); // Tutup bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pembayaran berhasil!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar transaksi yg belum lunas untuk pelanggan ini
    final debtTxsAsync = ref.watch(transactionsWithDebtProvider(widget.customer.id!));
    
    // Hitung sisa utang jika ada transaksi yg dipilih
    final remainingDebt = _selectedTransaction?.remainingDebt ?? 0;

    return Padding(
      // Padding untuk keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tingginya pas
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bayar Utang: ${widget.customer.name}", style: Theme.of(context).textTheme.headlineSmall),
            Text("Total Utang: Rp ${widget.customer.totalDebt.toStringAsFixed(0)}", style: const TextStyle(color: Colors.red)),
            const Divider(height: 24),
            
            // 1. Pilih Transaksi yang Mau Dibayar
            debtTxsAsync.when(
              data: (txs) => DropdownButtonFormField<Transaction>(
                value: _selectedTransaction,
                hint: const Text("Pilih Transaksi... (Wajib)"),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: txs.map((tx) {
                  return DropdownMenuItem(
                    value: tx,
                    child: Text("${tx.transactionNumber} (Sisa: Rp ${tx.remainingDebt.toStringAsFixed(0)})"),
                  );
                }).toList(),
                onChanged: (tx) {
                  setState(() {
                    _selectedTransaction = tx;
                    // Auto-fill jumlah bayar
                    _amountController.text = (tx?.remainingDebt ?? 0).toStringAsFixed(0);
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e,s) => const Text("Gagal memuat transaksi"),
            ),
            const SizedBox(height: 16),

            // 2. Masukkan Jumlah Bayar
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Jumlah Bayar (Maks: Rp $remainingDebt)",
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: _processPayment,
                child: const Text("Konfirmasi Pembayaran"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}