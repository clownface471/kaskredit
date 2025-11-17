import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/expenses/data/expense_repository.dart';
import 'package:kaskredit_1/shared/models/expense.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserProvider).value?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: User tidak login.")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newExpense = Expense(
        userId: userId,
        description: _descriptionController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        expenseDate: _selectedDate,
        createdAt: DateTime.now(),
      );

      await ref.read(expenseRepositoryProvider).addExpense(newExpense);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pengeluaran berhasil ditambahkan"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pengeluaran"),
        actions: [
          if (!_isLoading)
            IconButton(icon: const Icon(Icons.save), onPressed: _submit)
          else
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
            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Deskripsi Pengeluaran (Wajib)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: "Contoh: Bayar Listrik Bulan Ini",
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Deskripsi tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),

            // Jumlah
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Jumlah (Rp)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Jumlah tidak boleh kosong";
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return "Masukkan jumlah yang valid";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Kategori (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: "Contoh: Operasional, Gaji, Utilitas",
              ),
            ),
            const SizedBox(height: 16),

            // Tanggal
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Tanggal Pengeluaran",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Catatan
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: "Catatan (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
