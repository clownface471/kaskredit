import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:kaskredit_1/shared/models/customer.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final Customer customer;
  const PaymentDialog({super.key, required this.customer});

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  Transaction? _selectedTransaction;
  final _amountController = TextEditingController();
  
  // 1. TAMBAHKAN STATE _isLoading
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final paymentAmount = double.tryParse(_amountController.text) ?? 0;
    final userId = ref.read(currentUserProvider).value?.id;

    if (paymentAmount <= 0 || _selectedTransaction == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data tidak valid."), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. SET LOADING JADI TRUE
    setState(() => _isLoading = true);

    try {
      await ref.read(paymentRepositoryProvider).processPayment(
            transactionId: _selectedTransaction!.id!,
            customerId: widget.customer.id!,
            paymentAmount: paymentAmount,
            paymentMethod: "CASH",
            userId: userId,
            customerName: widget.customer.name,
          );
      
      if (mounted) {
        Navigator.of(context).pop();
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
    } finally {
      // 3. SET LOADING JADI FALSE
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final debtTxsAsync = ref.watch(transactionsWithDebtProvider(widget.customer.id!));
    final remainingDebt = _selectedTransaction?.remainingDebt ?? 0;

    // 4. LOGIKA UNTUK ENABLE/DISABLE TOMBOL
    final bool canSubmit = _selectedTransaction != null && !_isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bayar Utang: ${widget.customer.name}", style: Theme.of(context).textTheme.headlineSmall),
            Text("Total Utang: Rp ${widget.customer.totalDebt.toStringAsFixed(0)}", style: const TextStyle(color: Colors.red)),
            const Divider(height: 24),
            
            // 1. Pilih Transaksi
            debtTxsAsync.when(
              data: (txs) {
                
                // --- PERBAIKAN DIMULAI DI SINI ---
                // Cek apakah transaksi yang kita pilih SEKARANG
                // masih ada di dalam list baru dari stream.
                final bool isSelectionValid = _selectedTransaction != null &&
                    txs.any((tx) => tx.id == _selectedTransaction!.id);
                // --- AKHIR PERBAIKAN ---

                if (txs.isEmpty && !isSelectionValid) {
                  // Jika tidak ada transaksi DAN tidak ada yg dipilih
                  return const Text("Pelanggan ini tidak memiliki transaksi utang aktif.");
                }

                return DropdownButtonFormField<Transaction>(
                  // Jika seleksi sudah tidak valid (baru dibayar),
                  // set value ke null agar tidak crash
                  value: isSelectionValid ? _selectedTransaction : null,
                  hint: const Text("Pilih Transaksi... (Wajib)"),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: txs.map((tx) {
                    return DropdownMenuItem(
                      value: tx,
                      child: Text(
                          "${tx.transactionNumber} (Sisa: Rp ${tx.remainingDebt.toStringAsFixed(0)})"),
                    );
                  }).toList(),
                  onChanged: (tx) {
                    setState(() {
                      _selectedTransaction = tx;
                      _amountController.text =
                          (tx?.remainingDebt ?? 0).toStringAsFixed(0);
                    });
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const Text("Gagal memuat transaksi"),
            ),
            const SizedBox(height: 16),

            // 2. Masukkan Jumlah Bayar
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Jumlah Bayar (Maks: Rp ${remainingDebt.toStringAsFixed(0)})",
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
              height: 50, // Beri tinggi agar loading indicator pas
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) // Tampilkan loading
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      // 5. GUNAKAN LOGIKA 'canSubmit'
                      onPressed: canSubmit ? _processPayment : null, 
                      child: const Text("Konfirmasi Pembayaran"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}