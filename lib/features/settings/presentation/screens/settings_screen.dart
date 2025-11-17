import 'package:flutter/material.dart';

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
        children: const [
          ListTile(
            leading: Icon(Icons.store),
            title: Text("Profil Toko"),
            subtitle: Text("Ubah nama, alamat, dan logo toko"),
          ),
          ListTile(
            leading: Icon(Icons.print),
            title: Text("Pengaturan Struk"),
            subtitle: Text("Atur header & footer struk"),
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text("Manajemen Kasir"),
            subtitle: Text("Tambah atau hapus akun kasir"),
          ),
        ],
      ),
    );
  }
}