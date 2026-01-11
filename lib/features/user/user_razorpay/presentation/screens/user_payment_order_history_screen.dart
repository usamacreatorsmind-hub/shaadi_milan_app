import '../../domain/states/order.dart';
import '../notifier/order_notifier.dart';
import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class UserPaymentOrderHistoryScreen extends ConsumerStatefulWidget {
  const UserPaymentOrderHistoryScreen({super.key});

  @override
  ConsumerState<UserPaymentOrderHistoryScreen> createState() =>
      _UserPaymentHistoryScreenState();
}

class _UserPaymentHistoryScreenState
    extends ConsumerState<UserPaymentOrderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);
    final orders = state.orders;

    // Filter logic for tabs
    final successOrders = orders
        .where(
          (o) =>
              o.status.toLowerCase() == 'paid' ||
              o.status.toLowerCase() == 'success',
        )
        .toList();
    final pendingOrders = orders
        .where((o) => o.status.toLowerCase() == 'pending')
        .toList();
    final failedOrders = orders
        .where((o) => o.status.toLowerCase() == 'failed')
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      iconTheme: const IconThemeData(color: Colors.black),
                      title: const Text(
                        "Payment History",
                        style: TextStyle(color: Colors.black),
                      ),

                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                      bottom: const TabBar(
                        indicatorColor: Color.fromARGB(255, 207, 209, 211),
                        indicatorWeight: 3,
                        tabs: [
                          Tab(text: "Successful"),
                          Tab(text: "Pending"),
                          Tab(text: "Failed/Other"),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _OrderList(
                      orders: successOrders,
                      emptyMsg: "No successful payments",
                    ),
                    _OrderList(
                      orders: pendingOrders,
                      emptyMsg: "No pending payments",
                    ),
                    _OrderList(
                      orders: failedOrders,
                      emptyMsg: "No failed payments",
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// Reusable list widget to keep the TabBarView clean
class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String emptyMsg;

  const _OrderList({required this.orders, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final Order order;

  // Helper to determine status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'captured':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          /* Add navigation or detail expansion here */
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section: Status & Date ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    order.createdAt.toLocal().toString().split(
                      ' ',
                    )[0], // Simpler date format
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Main Info Section: Amount & Name ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${order.orderId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${(order.amount).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // --- Secondary Details Section (Grid-like) ---
              _buildDetailRow(Icons.email_outlined, order.email),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.phone_android_outlined, order.phone),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.payment_outlined,
                'Gateway: ${order.gateway}',
              ),

              const SizedBox(height: 12),

              // --- Footer: Subtle IDs ---
              Text(
                'RPID: ${order.razorpayOrderId}',
                style: const TextStyle(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
