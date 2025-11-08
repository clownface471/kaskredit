import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- TAMBAHKAN IMPORT INI
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/customer.dart'; // Ganti ke relative import

part 'customer_repository.g.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _customersRef;

  CustomerRepository() {
    _customersRef = _firestore.collection('customers');
  }

  // === READ ===
  Stream<List<Customer>> getCustomers(String userId) {
    return _customersRef
        .where('userId', isEqualTo: userId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromFirestore(doc);
      }).toList();
    });
  }

  // === CREATE ===
  Future<void> addCustomer(Customer customer) async {
    try {
      await _customersRef.add(customer.toJson());
    } catch (e) {
      throw Exception('Gagal menambah pelanggan: $e');
    }
  }

  // === UPDATE ===
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customersRef.doc(customer.id).update(customer.toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate pelanggan: $e');
    }
  }

  // === DELETE ===
  Future<void> deleteCustomer(String customerId) async {
    try {
      final doc = await _customersRef.doc(customerId).get();
      // Pastikan data ada sebelum mencoba mengaksesnya
      if (!doc.exists) {
        throw Exception('Pelanggan tidak ditemukan.');
      }
      final customer = Customer.fromFirestore(doc);

      if (customer.totalDebt > 0) {
        throw Exception(
            'Tidak dapat menghapus pelanggan yang masih memiliki utang.');
      }

      await _customersRef.doc(customerId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus pelanggan: $e');
    }
  }
} // <-- Pastikan closing brace ini ada (ini adalah baris ~48-50)

// Provider Riverpod untuk repository
@Riverpod(keepAlive: true)
CustomerRepository customerRepository(Ref ref) { // <-- Ganti ke Ref
  return CustomerRepository();
}