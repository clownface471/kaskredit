import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kaskredit_1/features/expenses/presentation/controllers/expense_controller.dart';
import 'package:kaskredit_1/shared/models/expense.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late DateTime _selectedDate;

  // Get expense from arguments
  late final Expense expense;

  @override
  void initState() {
    super.initState();
    
    // Get argument menggunakan GetX
    expense = Get.arguments as Expense;
    
    _descriptionController = TextEditingController(text: expense.description);
    _amountController = TextEditingController(
      text: expense.amount.toStringAsFixed(0),
    );
    _selectedDate = expense.expenseDate;
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

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<ExpenseController>();
    
    final updatedExpense = expense.copyWith(
      description: _descriptionController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      expenseDate: _selectedDate,
    );

    await controller.updateExpense(updatedExpense);
  }

  Future<void> _delete() async {
    final controller = Get.find<ExpenseController>();
    await controller.deleteExpense(expense);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pengeluaran"),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _update,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: _delete,
                ),
              ],
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
