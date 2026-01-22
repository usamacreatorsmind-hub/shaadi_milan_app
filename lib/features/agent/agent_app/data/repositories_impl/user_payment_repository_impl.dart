import '../datasources/user_payments_ds.dart';
import '../../domain/repositories/user_payments_repository.dart';
import '../../../../user/user_razorpay/domain/states/payment.dart';

class UserPaymentRepositoryImpl implements UserPaymentsRepository {
  final UserPaymentDs paymentsDs;

  UserPaymentRepositoryImpl(this.paymentsDs);

  @override
  Future<Payment?> getUserPayment({
    required String agentId,
    required String userId,
  }) {
    return paymentsDs.getUserPayment(userId: userId, agentId: agentId);
  }

  @override
  Future<List<Payment?>> getUsersPayment({required String agentId}) {
    return paymentsDs.getUsersPayment(agentId: agentId);
  }

  @override
  Future<List<Payment?>> getAfterMarriagePayments({required String agentId}) {
    return paymentsDs.getAfterMarriagePayments(agentId: agentId);
  }

  @override
  Future<Payment?> getAfterMarriagePaymentForUser({required String userId}) {
    return paymentsDs.getAfterMarriagePaymentForUser(userId: userId);
  }
}
