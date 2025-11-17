import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/expenses/data/expense_repository.dart';
import 'package:kaskredit_1/shared/models/expense.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final Expense expense; // Terima pengeluaran yang mau diedit
  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data yang ada
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(0),
    );
    _selectedDate = widget.expense.expenseDate;
    _dateController = TextEditingController(
      text: DateFormat('d MMM yyyy').format(_selectedDate),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('d MMM yyyy').format(_selectedDate);
      });
    }
  }

  // --- FUNGSI UPDATE ---
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Buat objek baru dengan .copyWith()
      final updatedExpense = widget.expense.copyWith(
        description: _descriptionController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        expenseDate: _selectedDate,
      );

      // Panggil repository (kita perlu buat method-nya)
      await ref.read(expenseRepositoryProvider).updateExpense(updatedExpense);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengupdate pengeluaran: $e")),
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  // --- FUNGSI DELETE ---
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pengeluaran?"),
        content: Text("Yakin ingin menghapus '${widget.expense.description}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });
    try {
      await ref
          .read(expenseRepositoryProvider)
          .deleteExpense(widget.expense.id!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pengeluaran"),
        actions: [
          if (!_isLoading) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _update, // Panggil _update
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _delete, // Panggil _delete
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Form-nya sama persis dengan AddExpenseScreen
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Deskripsi (Cth: Bayar Listrik)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Deskripsi tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Jumlah (Rp)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty)
                  ? "Jumlah tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Tanggal Pengeluaran",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
    );
  }
}
