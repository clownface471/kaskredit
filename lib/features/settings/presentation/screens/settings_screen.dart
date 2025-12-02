import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaskredit_1/core/navigation/app_routes.dart';
import 'package:kaskredit_1/features/auth/presentation/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxString shopName = ''.obs;
  final RxString shopAddress = ''.obs;
  final RxString shopPhone = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadShopInfo();
  }

  Future<void> _loadShopInfo() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        shopName.value = data['shopName'] ?? '';
        shopAddress.value = data['shopAddress'] ?? '';
        shopPhone.value = data['shopPhone'] ?? '';
      }
    } catch (e) {
      print('Error loading shop info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateShopInfo({
    required String name,
    required String address,
    required String phone,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'shopName': name,
        'shopAddress': address,
        'shopPhone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      shopName.value = name;
      shopAddress.value = address;
      shopPhone.value = phone;

      Get.snackbar(
        'Berhasil',
        'Informasi toko berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui informasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    }
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Shop Info Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.store),
                    ),
                    title: Text(
                      controller.shopName.value.isEmpty 
                          ? 'Toko Saya' 
                          : controller.shopName.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: controller.shopAddress.value.isEmpty
                        ? const Text('Belum ada alamat')
                        : Text(controller.shopAddress.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditShopDialog(context, controller),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Account Info
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Akun'),
                subtitle: Text(authController.currentUser?.email ?? ''),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 16),

            // Printer Settings
            _buildMenuItem(
              icon: Icons.print,
              title: "Pengaturan Printer",
              subtitle: "Atur printer thermal untuk cetak struk",
              onTap: () => Get.toNamed(AppRoutes.PRINTER_SETTINGS),
            ),
            const SizedBox(height: 8),

            // Data Management
            _buildMenuItem(
              icon: Icons.backup,
              title: "Backup Data",
              subtitle: "Backup data ke cloud storage",
              onTap: () {
                Get.snackbar("Info", "Fitur backup akan segera hadir");
              },
            ),
            const SizedBox(height: 8),

            // Help & Support
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Bantuan & Support",
              subtitle: "Panduan penggunaan aplikasi",
              onTap: () {
                Get.snackbar("Info", "Fitur bantuan akan segera hadir");
              },
            ),
            const SizedBox(height: 8),

            // About
            _buildMenuItem(
              icon: Icons.info_outline,
              title: "Tentang Aplikasi",
              subtitle: "KasKredit v1.0.0",
              onTap: () => _showAboutDialog(context),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Keluar"),
                onPressed: () => _confirmLogout(authController),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showEditShopDialog(BuildContext context, SettingsController controller) {
    final nameCtrl = TextEditingController(text: controller.shopName.value);
    final addressCtrl = TextEditingController(text: controller.shopAddress.value);
    final phoneCtrl = TextEditingController(text: controller.shopPhone.value);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Informasi Toko'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateShopInfo(
                name: nameCtrl.text,
                address: addressCtrl.text,
                phone: phoneCtrl.text,
              );
              Get.back();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Tentang KasKredit'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KasKredit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Versi 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Aplikasi kasir dan manajemen kredit untuk UMKM',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 KasKredit. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}