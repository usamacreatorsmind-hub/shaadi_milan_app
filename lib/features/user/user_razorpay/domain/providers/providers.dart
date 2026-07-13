export 'package:shadi_milan/features/user/user_razorpay/domain/repository/amount_repository.dart';
export 'package:shadi_milan/features/user/user_razorpay/domain/repository/order_repository.dart';
export 'package:shadi_milan/features/user/user_razorpay/domain/repository/payment_repository.dart';
import 'package:shadi_milan/features/user/user_razorpay/data/providers/providers.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/repository/amount_repository.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/repository/order_repository.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/repository/payment_repository.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/amount.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/amount_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.watch(paymentFirestoreProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(orderFirestoreProvider));
});

final amountRepositoryProvider = Provider<AmountRepository>((ref) {
  return AmountRepository(
    amountFirestoreDS: ref.watch(amountFirestoreProvider),
  );
});

final postMarriageAmountMaleRepositoryProvider = Provider<AmountRepository>((
  ref,
) {
  return AmountRepository(
    amountFirestoreDS: ref.watch(amountFirestoreProvider),
  );
});

final postMarriageAmountFemaleRepositoryProvider = Provider<AmountRepository>((
  ref,
) {
  return AmountRepository(
    amountFirestoreDS: ref.watch(amountFirestoreProvider),
  );
});

final postMarriageAmountMaleNotifierProvider =
    StateNotifierProvider<AmountNotifier, AmountState>((ref) {
      return AmountNotifier(ref.read(postMarriageAmountMaleRepositoryProvider));
    });

final postMarriageAmountFemaleNotifierProvider =
    StateNotifierProvider<AmountNotifier, AmountState>((ref) {
      return AmountNotifier(
        ref.read(postMarriageAmountFemaleRepositoryProvider),
      );
    });
