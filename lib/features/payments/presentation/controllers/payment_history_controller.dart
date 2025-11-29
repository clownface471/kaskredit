import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaskredit_1/features/payments/data/payment_repository.dart';
import 'package:kaskredit_1/shared/models/payment.dart';

class PaymentHistoryController extends GetxController {
  final PaymentRepository _repository = PaymentRepository();
  
  final RxList<Payment> payments = <Payment>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _bindPaymentStream();
  }

  void _bindPaymentStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isLoading.value = true;
    
    payments.bindStream(_repository.getAllPayments(userId));
    
    ever(payments, (_) => isLoading.value = false);
  }
}