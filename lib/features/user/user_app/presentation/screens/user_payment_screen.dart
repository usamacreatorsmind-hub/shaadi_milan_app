import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserPaymentScreen extends StatelessWidget {
  const UserPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                MatrimonySubscriptionCard(
                  planName: "Premium",
                  price: "₹1099",
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

// class MatrimonySubscriptionCard extends StatelessWidget {
//   final String planName;
//   final String price;
//   final String duration;
//   final List<String> features;
//   final VoidCallback onSubscribe;

//   const MatrimonySubscriptionCard({
//     super.key,
//     required this.planName,
//     required this.price,
//     required this.duration,
//     required this.features,
//     required this.onSubscribe,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(28),
//         gradient: LinearGradient(
//           colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.92)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: theme.primaryColor.withOpacity(0.35),
//             blurRadius: 28,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 👑 Header
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.25),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.workspace_premium,
//                     color: Colors.white,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   planName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // 💰 Price
//             RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: price,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextSpan(
//                     text: " / $duration",
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.85),
//                       fontSize: 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 22),

//             // ✨ Features
//             ...features.map(
//               (feature) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.25),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.check,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         feature,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 26),

//             // 🚀 CTA
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: theme.primaryColor,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: onSubscribe,
//                 child: const Text("Upgrade Now"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MatrimonySubscriptionCard extends StatelessWidget {
  final String planName;
  final String price;
  final String duration; // "One Time"
  final List<String> features;
  final VoidCallback onSubscribe;

  const MatrimonySubscriptionCard({
    super.key,
    required this.planName,
    required this.price,
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
              price,
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
