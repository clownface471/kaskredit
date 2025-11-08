import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kaskredit_1/shared/models/customer.dart'; // Import model baru kita

part 'customer_repository.g.dart'; // Akan dibuat otomatis

class CustomerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _customersRef;

  CustomerRepository() {
    _customersRef = _firestore.collection('customers');
  }

  // === READ ===
  // Stream untuk mendapatkan semua pelanggan secara real-time
  Stream<List<Customer>> getCustomers(String userId) {
    return _customersRef
        .where('userId', isEqualTo: userId)
        .orderBy('name') // Urutkan berdasarkan nama
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
  [cite_start]// Sesuai blueprint[cite: 788], kita cek dulu utangnya
  Future<void> deleteCustomer(String customerId) async {
    try {
      // Ambil data pelanggan dulu
      final doc = await _customersRef.doc(customerId).get();
      final customer = Customer.fromFirestore(doc);

      // Logika pengaman: Jangan hapus jika masih punya utang
      if (customer.totalDebt > 0) {
        throw Exception(
            'Tidak dapat menghapus pelanggan yang masih memiliki utang.');
      }
      
      await _customersRef.doc(customerId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus pelanggan: $e');
    }
  }
}

// Provider Riverpod untuk repository
@Riverpod(keepAlive: true)
CustomerRepository customerRepository(Ref ref) {
  return CustomerRepository();
}