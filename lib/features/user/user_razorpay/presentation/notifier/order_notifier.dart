import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/providers/providers.dart';
import '../../domain/states/order.dart';

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _orderRepository;
  final String _uid;

  OrderNotifier(this._orderRepository, this._uid) : super(OrderState.initial) {
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ordersMap = await _orderRepository.getPaymentHistory(_uid);
      final orders = ordersMap.map((map) => Order.fromMap(map)).toList();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  // fetch paymet for payment repository

  Future<void> fetchPayment() async {
    state = state.copyWith(isLoading: true, error: null);
    try {} catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final orderRepository = ref.read(orderRepositoryProvider);
  final authState = ref.read(authStateProvider);
  final uid = authState.value?.fold((agent) => agent.uid, (user) => user.uid);
  if (uid == null) {
    throw Exception('User not authenticated');
  }
  return OrderNotifier(orderRepository, uid);
});
