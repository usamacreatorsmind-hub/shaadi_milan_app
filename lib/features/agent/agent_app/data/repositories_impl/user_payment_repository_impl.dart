import 'package:arvika_marriage_bureau/features/agent/agent_app/data/datasources/user_payments_ds.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/domain/repositories/user_payments_repository.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment.dart';

class UserPaymentRepositoryImpl implements UserPaymentsRepository {
  final UserPaymentDs paymentsDs;

  UserPaymentRepositoryImpl(this.paymentsDs);

  @override
  Future<Payment?> getUserPayment({
    required String agentid,
    required String userId,
  }) {
    return paymentsDs.getUserPayment(
      userId: userId,
      agentId:
          agentid, // Agent ID is not available here, pass an empty string or handle it as per your logic
    );
  }

  @override
  Future<List<Payment?>> getUsersPayment() {
    return paymentsDs.getUsersPayment();
  }
}
