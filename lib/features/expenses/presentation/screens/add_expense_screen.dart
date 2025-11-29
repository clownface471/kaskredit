import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:kaskredit_1/shared/models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('d MMM yyyy').format(_selectedDate);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<ExpenseController>();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      Get.snackbar(
        'Error',
        'User tidak terautentikasi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final expense = Expense(
      userId: userId,
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      expenseDate: _selectedDate,
      createdAt: DateTime.now(),
    );

    await controller.addExpense(expense);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pengeluaran"),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            return IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
            );
          }),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
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
              textCapitalization: TextCapitalization.sentences,
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
