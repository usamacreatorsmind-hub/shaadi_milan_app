import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/features/auth/presentation/providers/auth_providers.dart';
import 'package:shadi_milan/features/user/user_app/presentation/screens/user_profile_screen.dart';
import 'package:shadi_milan/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:shadi_milan/features/user/user_razorpay/domain/states/payment.dart';
import 'package:shadi_milan/app/router/app_router.dart';
import '../../../../auth/domain/states/user_state.dart';
import '../../../user_app/data/repositories_impl/user_repo_impl.dart';
import '../../../user_app/presentation/utils/profile_action_gate.dart';
import '../notifier/payment_api_notifier.dart';

@RoutePage()
class UserPremiumPlansScreen extends ConsumerWidget {
  const UserPremiumPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final userId = user?.uid ?? '';
    final paymentState = ref.watch(paymentNotifierProvider(userId));
    final isPremium = paymentState.status == PayStatus.success;

    // Listen for payment success/failure
    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (next.status == PayStatus.success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Payment Successful"),
            content: const Text("Thank you! Your payment has been received. Your premium features will be active shortly."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.router.popUntilRoot();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else if (next.status == PayStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment Failed. Please try again.'), backgroundColor: Colors.red));
      }
    });

    final plans = [
      _PremiumPlan(
        title: "Basic",
        price: "1,100",
        duration: "1 Month",
        description: "Perfect to start your journey",
        features: ["Unlimited Chat", "View 50 Contacts", "Profile Boost (24h)", "Basic Filters"],
        color: const Color(0xFF4FC3F7),
        icon: Icons.rocket_launch_outlined,
      ),
      _PremiumPlan(
        title: "Gold",
        price: "3,000",
        duration: "3 Months",
        description: "Most popular choice for serious seekers",
        features: ["Unlimited Chat", "View 150 Contacts", "Priority Support", "Personal Matchmaker", "Advanced Filters"],
        isPopular: true,
        color: theme.primaryColor,
        icon: Icons.star_rounded,
        savings: "SAVE 10%",
      ),
      _PremiumPlan(
        title: "Diamond",
        price: "5,500",
        duration: "6 Months",
        description: "Premium features for faster matching",
        features: [
          "Unlimited Chat",
          "View 350 Contacts",
          "Priority Support",
          "Profile Highlight",
          "Advanced Matchmaking",
          "Incognito Mode",
        ],
        color: const Color(0xFFF06292),
        icon: Icons.diamond_rounded,
        savings: "SAVE 15%",
      ),
      _PremiumPlan(
        title: "Platinum",
        price: "10,000",
        duration: "12 Months",
        description: "VIP treatment for the ultimate success",
        features: [
          "Unlimited Chat",
          "Unlimited Views",
          "VIP Dedicated Support",
          "Profile Highlight",
          "Dedicated Relationship Manager",
          "Custom Preferences",
        ],
        color: const Color(0xFF7986CB),
        icon: Icons.workspace_premium_rounded,
        savings: "BEST VALUE",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.primaryColor,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "Premium Membership",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, const Color(0xFFE91E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(right: -30, top: -20, child: Icon(Icons.favorite, size: 200, color: Colors.white.withOpacity(0.1))),
                  Positioned(left: -20, bottom: 20, child: Icon(Icons.auto_awesome, size: 120, color: Colors.white.withOpacity(0.1))),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isPremium) ...[
                          Text(
                            "${user?.fullName.en ?? 'User'}, welcome to",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            "your Premium experience",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Step up to Premium",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Find your life partner 10x faster",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isPremium && paymentState.payment != null) SliverToBoxAdapter(child: _ActivePlanCard(payment: paymentState.payment!)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: theme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "TRANSPARENT PRICING",
                      style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select a Plan that fits You",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Get access to all premium features and tools",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _PlanCard(plan: plans[index], userId: userId);
              }, childCount: plans.length),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, color: Colors.green, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Safe & Secure Payments",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _FeatureRow(
                    icon: Icons.chat_bubble_rounded,
                    title: "Instant Messages",
                    subtitle: "Start chatting immediately with your matches",
                  ),
                  const _FeatureRow(
                    icon: Icons.visibility_rounded,
                    title: "Who Viewed You",
                    subtitle: "See which profiles are interested in you",
                  ),
                  const _FeatureRow(
                    icon: Icons.star_rate_rounded,
                    title: "Profile Booster",
                    subtitle: "Get your profile listed at the top of search results",
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  final Payment payment;

  const _ActivePlanCard({required this.payment});

  String _getPlanName(int amount) {
    if (amount >= 10000) return "Platinum Plus";
    if (amount >= 5500) return "Diamond Plan";
    if (amount >= 3000) return "Gold Plan";
    return "Basic Plan";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planName = _getPlanName(payment.amount);
    final startDateStr = DateFormat('d MMM, yyyy').format(payment.createdAt);
    // Assuming 1 year for now, or you can calculate based on plan
    final expiryDate = payment.createdAt.add(const Duration(days: 365));
    final expiryDateStr = DateFormat('d MMM, yyyy').format(expiryDate);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                planName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  "Active",
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [_buildDateItem("Start Date", startDateStr), const SizedBox(width: 24), _buildDateItem("Expiry", expiryDateStr)]),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ],
    );
  }
}

class _PremiumPlan {
  final String title;
  final String price;
  final String duration;
  final String description;
  final List<String> features;
  final bool isPopular;
  final Color color;
  final IconData icon;
  final String? savings;

  _PremiumPlan({
    required this.title,
    required this.price,
    required this.duration,
    required this.description,
    required this.features,
    this.isPopular = false,
    required this.color,
    required this.icon,
    this.savings,
  });
}

class _PlanCard extends ConsumerWidget {
  final _PremiumPlan plan;
  final String userId;

  const _PlanCard({required this.plan, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: plan.isPopular ? plan.color.withOpacity(0.3) : Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: plan.isPopular ? plan.color.withOpacity(0.08) : Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            if (plan.isPopular)
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: plan.color.withOpacity(0.05), shape: BoxShape.circle),
                ),
              ),
            if (plan.isPopular)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: plan.color,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20)),
                  ),
                  child: const Text(
                    "POPULAR",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
            if (plan.savings != null)
              Positioned(
                left: 24,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: Text(
                    plan.savings!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: plan.color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                        child: Icon(plan.icon, color: plan.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            Text(
                              plan.duration,
                              style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${plan.price}",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: plan.color),
                          ),
                          if (plan.title != "Basic")
                            Text(
                              "avg. ₹${(int.parse(plan.price.replaceAll(',', '')) / int.parse(plan.duration.split(' ')[0])).round()}/mo",
                              style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    plan.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ...plan.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 14, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            f,
                            style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handlePayment(context, ref, userId, double.parse(plan.price.replaceAll(',', ''))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.color,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: plan.color.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        "CHOOSE THIS PLAN",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePayment(BuildContext context, WidgetRef ref, String userId, double amount) async {
    final theme = Theme.of(context);
    final userProfileAsync = await ref.read(userProfileScreenProvider(userId).future);
    if (!context.mounted) return;

    // Enforce Step 1 before Step 2: complete profile before purchasing Premium
    final canProceed = ProfileActionGate.ensureProfileComplete(
      context,
      isProfileCreated: userProfileAsync.user.isProfileCreated,
      title: 'Complete Your Profile First',
      subtitle: 'Please complete your 9-step matrimony profile before purchasing a Premium plan.',
      showPremiumStep: true,
    );
    if (!canProceed) return;

    if (userProfileAsync.user.agentId.isEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        backgroundColor: theme.canvasColor,
        builder: (context) => const AgentFormWidget(),
      );
      return;
    }

    final user = userProfileAsync.user;
    final profile = userProfileAsync.metrimonyProfile;

    final region = profile.address.state.en.isEmpty ? "Not Provided" : profile.address.state.en;
    final district = profile.address.city.en.isEmpty ? "Not Provided" : profile.address.city.en;
    final gender = profile.identity.gender.en.isEmpty ? "Not Provided" : profile.identity.gender.en;

    final agentCommission = userProfileAsync.agentEntity?.calculateCommission(amount) ?? 0.0;
    final commissionRate = userProfileAsync.agentEntity?.commissionRate ?? 0.0;
    final agentDesignation = userProfileAsync.agentEntity?.designation.label ?? 'N/A';

    ref
        .read(paymentProvider.notifier)
        .startPayment(
          paymentType: "PREMIUM",
          amount: amount,
          uid: user.uid,
          email: user.email,
          fullName: user.fullName.en,
          phone: user.phone,
          agentId: user.agentId,
          region: region,
          district: district,
          gender: gender,
          agentCommission: agentCommission,
          commissionRate: commissionRate,
          agentDesignation: agentDesignation,
        );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: Colors.orange.shade700, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
