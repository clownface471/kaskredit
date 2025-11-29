import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/transactions/data/transaction_repository.dart';
import 'package:kaskredit_1/shared/models/transaction.dart';

class TransactionHistoryController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();
  
  // State: List Transaksi (Reactive)
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindTransactionStream();
  }

  void _bindTransactionStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    
    // Bind stream dari repository langsung ke variabel rx
    transactions.bindStream(
      _repository.getTransactionHistory(userId)
    );
    
    // Matikan loading saat stream pertama kali masuk data (sedikit trick)
    // Sebenarnya bindStream otomatis update, tapi untuk loading indicator awal:
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) isLoading.value = false;
    });
    
    // Listener manual untuk mematikan loading jika stream sudah emit data
    ever(transactions, (_) => isLoading.value = false);
  }
}