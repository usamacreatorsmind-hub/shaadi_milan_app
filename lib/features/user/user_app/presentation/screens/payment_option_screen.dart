import 'svg.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PaymentOptionScreen extends StatelessWidget {
  const PaymentOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Payment Option"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your preferred payment method to complete your premium upgrade.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            _PaymentOptionTile(
              icon: Icons.credit_card,
              title: "Credit/Debit Card",
              subtitle: Text("Visa, MasterCard, Rupay, etc."),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Initiating card payment..."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Implement navigation to card payment gateway
              },
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              icon: Icons.account_balance_wallet,
              title: "UPI (Unified Payments Interface)",
              // subtitle: "Google Pay, PhonePe, Paytm, BHIM, etc.",
              subtitle: _buildPaymentTile(),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Initiating UPI payment..."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Implement navigation to UPI payment gateway
              },
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              icon: Icons.account_balance,
              title: "Net Banking",
              subtitle: Text(
                "All major Indian banks",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Initiating Net Banking payment..."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Implement navigation to Net Banking payment gateway
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Google Pay, PhonePe, Paytm, BHIM, etc.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 10),
           
          
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget subtitle;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: theme.primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
