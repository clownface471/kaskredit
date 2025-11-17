import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/product.dart';

part 'product_repository.g.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _productsRef;

  ProductRepository() {
    _productsRef = _firestore.collection('products');
  }

  // === READ ===
  Stream<List<Product>> getProducts(String userId) {
    return _productsRef
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }

  // === CREATE ===
  Future<void> addProduct(Product product) async {
    try {
      await _productsRef.add(product.toJson());
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  // === UPDATE ===
  Future<void> updateProduct(Product product) async {
    try {
      await _productsRef.doc(product.id).update(product.toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }

  // === DELETE ===
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).update({'isActive': false});
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }
}

@Riverpod(keepAlive: true)
ProductRepository productRepository(Ref ref) {
  return ProductRepository();
}