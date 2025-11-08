import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/customers/data/customer_repository.dart';
import 'package:kaskredit_1/shared/models/customer.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final Customer customer;

  const EditCustomerScreen({super.key, required this.customer});

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
    _addressController = TextEditingController(text: widget.customer.address);
    _notesController = TextEditingController(text: widget.customer.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // === FUNGSI UPDATE ===
  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updatedCustomer = widget.customer.copyWith(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        notes: _notesController.text,
        updatedAt: DateTime.now(),
      );

      await ref.read(customerRepositoryProvider).updateCustomer(updatedCustomer);

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal update: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // === FUNGSI DELETE ===
  Future<void> _delete() async {
    // 1. Cek Utang Dulu (Pencegahan di UI)
    if (widget.customer.totalDebt > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal: Pelanggan ini masih memiliki utang."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Dialog Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pelanggan?"),
        content: Text("Yakin ingin menghapus '${widget.customer.name}'?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Hapus")),
        ],
      ),
    );

    if (confirm != true) return;

    // 3. Eksekusi Hapus
    setState(() => _isLoading = true);
    try {
      await ref
          .read(customerRepositoryProvider)
          .deleteCustomer(widget.customer.id!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pelanggan"),
        actions: [
          if (!_isLoading) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _update,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _delete,
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: "Nama Pelanggan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)),
              validator: (val) =>
                  val!.isEmpty ? "Nama tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: "Nomor HP",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                  labelText: "Alamat",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on)),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: "Catatan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note)),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}