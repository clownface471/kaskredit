import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/auth/presentation/providers/auth_providers.dart';
import 'package:kaskredit_1/features/customers/data/customer_repository.dart';
import 'package:kaskredit_1/shared/models/customer.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller untuk setiap field
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Dapatkan user ID
    final userId = ref.read(currentUserProvider).value?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User tidak ditemukan.")),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 3. Buat objek Customer baru
      final newCustomer = Customer(
        userId: userId,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        notes: _notesController.text,
        totalDebt: 0.0, // Utang awal selalu 0
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 4. Panggil repository untuk menyimpan ke Firestore
      await ref.read(customerRepositoryProvider).addCustomer(newCustomer);

      // 5. Kembali ke halaman list pelanggan
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan pelanggan: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Pelanggan Baru"),
        actions: [
          // Tombol Simpan
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _submit,
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Nama Pelanggan (Wajib)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Pelanggan (Wajib)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? "Nama pelanggan tidak boleh kosong"
                  : null,
            ),
            const SizedBox(height: 16),
            // Nomor HP (Opsional)
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Nomor HP (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Alamat (Opsional)
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Alamat (Opsional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Catatan (Opsional)
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