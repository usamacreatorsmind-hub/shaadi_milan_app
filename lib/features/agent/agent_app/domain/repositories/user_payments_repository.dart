import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';

abstract class UserPaymentsRepository {
  Future<Payment?> getUserPayment({
    required String agentId,
    required String userId,
  });

  Future<List<Payment?>> getUsersPayment();
}
