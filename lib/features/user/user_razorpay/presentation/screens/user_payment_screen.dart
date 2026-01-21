import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/core/notification/in_app_messaging_service.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_profile_screen.dart';

import '../../../user_app/domain/states/metrimony_profile_view_model.dart';
import '../../domain/states/payment.dart';
import '../notifier/amount_notifier.dart';
import '../notifier/payment_api_notifier.dart';
import '../notifier/payment_notifier.dart';

@RoutePage()
class UserPaymentScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserPaymentScreen({super.key, required this.userId});

  @override
  ConsumerState<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends ConsumerState<UserPaymentScreen> {
  int _currentIndex = 1; // Default Premium

  @override
  void initState() {
    super.initState();
    // Suppress In-App Messages during payment flow to prevent interruptions
    InAppMessagingService.setSuppressed(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paymentNotifierProvider(widget.userId).notifier)
          .fetchUserPayment();
    });
  }

  @override
  void dispose() {
    // Re-enable In-App Messages when leaving the screen
    InAppMessagingService.setSuppressed(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountState = ref.watch(amountNotifierProvider);
    final paymentState = ref.watch(paymentProvider);
    ref.watch(paymentNotifierProvider(widget.userId));
    final userProfileAsync = ref.watch(
      userProfileScreenProvider(widget.userId),
    );
    // fetch metrimony profile also

    // Listen for payment success/failure to handle navigation/dialogs
    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (next.status == PayStatus.success) {
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
                  context.router.maybePop(); // Go back to previous screen
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else if (next.status == PayStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed:  '),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // fetch all data   from app user

    // if (existingPaymentState.status == PayStatus.success) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(Icons.verified, size: 100, color: theme.primaryColor),
    //           const SizedBox(height: 20),
    //           Text(
    //             "You are already a Premium Member",
    //             style: theme.textTheme.headlineSmall,
    //           ),
    //           const SizedBox(height: 20),
    //           ElevatedButton(
    //             onPressed: () =>
    //                 context.router.replaceAll([const UserMainShellRoute()]),
    //             child: const Text("Go to Home"),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (data) => Container(
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
                  else if (paymentState.status == PayStatus.loading)
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
                                .fetchRegistrationAmount(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 420,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.88),
                        itemCount: plans.length,
                        onPageChanged: (index) {
                          setState(() => _currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          final isSelected = index == _currentIndex;

                          return AnimatedScale(
                            scale: isSelected ? 1 : 0.94,
                            duration: const Duration(milliseconds: 300),
                            child: MatrimonySubscriptionCard(
                              planName: plan.name,
                              amount: "₹${amountState.amount!.amount}",
                              duration: "One Time",
                              features: plan.features,
                              isPopular: plan.isPopular,
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          final selectedPlan = plans[_currentIndex];

                          debugPrint("Selected Plan: ${selectedPlan.name}");

                          // ✅ Extract all user profile data
                          final profile = data.metrimonyProfile;
                          final user = data.user;

                          if (user.agentId.isEmpty) {
                            // create a model bottom sheet  to take user id or  show contact details if he does not know
                            print(" inside bottom sheet");
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,

                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),

                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.9,
                              ),
                              // theme color
                              backgroundColor: theme.canvasColor,
                              builder: (BuildContext context) {
                                return AgentFormWidget();
                              },
                            );

                            return;
                          }

                          debugPrint("Profile: $profile");

                          // Extract Address Data (Region/District/State)
                          final region = profile.address.state.trim().isEmpty
                              ? "Not Provided"
                              : profile.address.state;

                          final district = profile.address.city.trim().isEmpty
                              ? "Not Provided"
                              : profile.address.city;

                          // Extract Identity Data (Gender)
                          final gender = profile.identity.gender.trim().isEmpty
                              ? "Not Provided"
                              : profile.identity.gender;

                          // Extract Phone (user or address)

                          // Log all extracted data
                          debugPrint("\n=== 📋 PAYMENT DATA ===");
                          debugPrint("User UID: ${user.uid}");
                          debugPrint("Full Name: ${user.fullName}");
                          debugPrint("Email: ${user.email}");
                          debugPrint("Phone: $user.phone");
                          debugPrint("Agent ID: ${user.agentId}");
                          debugPrint("Region/State: $region");
                          debugPrint("District/City: $district");
                          debugPrint("Gender: $gender");
                          debugPrint("Amount: ${amountState.amount?.amount}");
                          debugPrint("=====================SA=\n");

                          ref
                              .read(paymentProvider.notifier)
                              .startPayment(
                                paymentType: amountState.amount!.paymentType,
                                amount: amountState.amount!.amount.toDouble(),
                                uid: user.uid,
                                email: user.email ?? "N/A",
                                fullName: user.fullName ?? "N/A",
                                phone: user.phone,
                                agentId: user.agentId,
                                region: region,
                                district: district,
                                gender: gender,
                              );
                        },
                        child: const Text("Pay Once & Unlock Premium"),
                      ),
                    ),
                  ),

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
      ),
    );
  }
}

class MatrimonySubscriptionCard extends StatelessWidget {
  final String planName;
  final String amount;
  final String duration;
  final List<String> features;
  final bool isPopular;

  const MatrimonySubscriptionCard({
    super.key,
    required this.planName,
    required this.amount,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.9)],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.35),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  planName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isPopular)
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
                      "MOST POPULAR",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),
            Text(
              "Pay once • Lifetime access",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
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
          ],
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String name;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.name,
    required this.features,
    this.isPopular = false,
  });
}

final List<SubscriptionPlan> plans = const [
  SubscriptionPlan(
    name: "Basic",
    features: ["Unlimited Matches", "Profile Viewing", "Interest Sending"],
  ),
  SubscriptionPlan(
    name: "Premium",
    isPopular: true,
    features: [
      "Unlimited Matches",
      "Advanced Filters",
      "Profile Boost",
      "Direct Chat Access",
      "Ad-Free Experience",
    ],
  ),
  SubscriptionPlan(
    name: "Elite",
    features: [
      "Everything in Premium",
      "Priority Profile Listing",
      "Personal Matchmaker Support",
      "Exclusive Elite Profiles",
    ],
  ),
];
