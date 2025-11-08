import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kaskredit_1/features/customers/presentation/providers/customer_providers.dart';

// 1. Ubah jadi ConsumerWidget
class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  // 2. Tambahkan WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. "Tonton" provider customers
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pelanggan"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti kita buat halaman AddCustomer
          context.push('/customers/add');
        },
        child: const Icon(Icons.add),
      ),
      // 4. Gunakan .when() untuk handle state (loading, error, data)
      body: customersAsync.when(
        // === State Sukses (Data Diterima) ===
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(
              child: Text("Belum ada pelanggan. Tekan tombol + untuk menambah."),
            );
          }

          // Tampilkan ListView
          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0].toUpperCase()), // Inisial
                  ),
                  title: Text(customer.name),
                  // Tampilkan utang jika ada
                  subtitle: Text(customer.totalDebt > 0 
                      ? "Utang: Rp ${customer.totalDebt.toStringAsFixed(0)}" 
                      : "Tidak ada utang"
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Nanti kita arahkan ke halaman edit
                    context.push('/customers/edit/${customer.id}');
                  },
                ),
              );
            },
          );
        },
        // === State Error ===
        error: (err, stack) => Center(
          child: Text("Error memuat pelanggan: $err"),
        ),
        // === State Loading ===
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}