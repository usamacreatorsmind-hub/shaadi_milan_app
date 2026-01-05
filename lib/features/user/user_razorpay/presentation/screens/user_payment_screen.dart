import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/domain/states/payment_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/providers/payment_provider.dart';

import '../../../../../app/router/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifier/amount_notifier.dart'; 

@RoutePage()
class UserPaymentScreen extends ConsumerStatefulWidget {
  final AppUser appUser;
  const UserPaymentScreen({super.key, required this.appUser});

  @override
  ConsumerState<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends ConsumerState<UserPaymentScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(paymentProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountState = ref.watch(amountNotifierProvider);
    final paymentState = ref.watch(paymentProvider);

    // Listen for payment success/failure to handle navigation/dialogs
    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (next.status == PaymentStatus.success) {
        // Show Success Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Successful"),
            content: const Text(
              "Thank you! Your payment has been received. Your premium features will be active shortly.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  context.router.pop(); // Go back to previous screen
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else if (next.status == PaymentStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? "Payment Failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // fetch all data   from app user

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.12),
              theme.primaryColor.withOpacity(0.04),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Title
                Text(
                  "Go Premium",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                // 🔹 Subtitle
                Text(
                  "Get better matches & faster connections",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),

                const SizedBox(height: 20),

                // ⭐ Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "MOST POPULAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 💎 Subscription Card
                if (amountState.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (paymentState.status == PaymentStatus.loading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (amountState.error != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Failed to load price",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(amountNotifierProvider.notifier)
                              .fetchAmount(),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                else
                  MatrimonySubscriptionCard(
                    planName: "Premium",
                    amount: amountState.amount != null
                        ? "₹${amountState.amount!.amount}"
                        : "₹--",
                    duration: "One Time",
                    features: const [
                      "Unlimited Matches",
                      "Advanced Filters",
                      "Profile Boosts",
                      "Ad-Free Experience",
                    ],
                    onSubscribe: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Redirecting to secure payment…"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // print all data here
                      debugPrint("User ID: ${widget.appUser.uid}");
                      debugPrint("User Email: ${widget.appUser.email}");
                      debugPrint("User Full Name: ${widget.appUser.fullName}");
                      debugPrint("User Phone: ${widget.appUser.phone}");
                      debugPrint(
                        "Amount: ${amountState.amount!.amount.toDouble()}",
                      );

                      ref
                          .read(paymentProvider.notifier)
                          .startOneTimePayment(
                            amount: amountState.amount!.amount.toDouble(),
                            uid: widget.appUser.uid,
                            email: widget.appUser.email,
                            fullName: widget.appUser.fullName,
                            phone: widget.appUser.phone,
                          );
                    },
                  ),

                const SizedBox(height: 20),

                // 🔒 Footer Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Secure payment • Cancel anytime • No hidden charges",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MatrimonySubscriptionCard extends StatelessWidget {
  final String planName;
  final String amount;
  final String duration; // "One Time"
  final List<String> features;
  final VoidCallback onSubscribe;

  const MatrimonySubscriptionCard({
    super.key,
    required this.planName,
    required this.amount,
    required this.duration,
    required this.features,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👑 Header + One Time Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // 🔥 ONE TIME BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "ONE-TIME",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 💰 Price (No /month)
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // 🔁 Lifetime Text
            Text(
              "Pay once • Lifetime access",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            // ✨ Features
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            // 🚀 CTA
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onSubscribe,
                child: const Text("Pay Once & Unlock Premium"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
