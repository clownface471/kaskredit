import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan Toko"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Profil Toko"),
            subtitle: const Text("Ubah nama, alamat, dan logo toko"),
            onTap: () {
              // TODO: Implement profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text("Pengaturan Printer"),
            subtitle: const Text("Atur printer thermal untuk cetak struk"),
            onTap: () {
              context.push('/settings/printer');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Manajemen Kasir"),
            subtitle: const Text("Tambah atau hapus akun kasir"),
            onTap: () {
              // TODO: Implement cashier management
            },
          ),
        ],
      ),
    );
  }
}