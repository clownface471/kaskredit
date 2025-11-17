import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/models/expense.dart'; // Import model baru

part 'expense_repository.g.dart'; // Akan dibuat

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _expensesRef;

  ExpenseRepository()
    : _expensesRef = FirebaseFirestore.instance.collection('expenses');

  // === READ ===
  Stream<List<Expense>> getExpenses(String userId) {
    return _expensesRef
        .where('userId', isEqualTo: userId)
        .orderBy('expenseDate', descending: true) // Terbaru di atas
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
        );
  }

  // === CREATE ===
  Future<void> addExpense(Expense expense) async {
    try {
      await _expensesRef.add(expense.toJson());
    } catch (e) {
      throw Exception('Gagal menambah pengeluaran: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      // Pastikan ID tidak null
      if (expense.id == null) {
        throw Exception("ID Pengeluaran tidak valid untuk update.");
      }
      await _expensesRef.doc(expense.id).update(expense.toJson());
    } catch (e) {
      throw Exception('Gagal mengupdate pengeluaran: $e');
    }
  }

  // === DELETE ===
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expensesRef.doc(expenseId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus pengeluaran: $e');
    }
  }
}

// Provider Riverpod
@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepository();
}
