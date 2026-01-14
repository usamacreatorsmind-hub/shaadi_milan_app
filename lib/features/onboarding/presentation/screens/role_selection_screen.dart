import '../../../../app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:ui'; // Required for ImageFilter

@RoutePage()
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE0E6), // Soft Pink
              Color(0xFFFFF5F7), // Very Light Pink
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      /// 💍 App Branding with Animation
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            // circle avatar
                            CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 200,
                                height: 200,
                              ),
                            ),

                            Text(
                              'Arvika Marriage Bureau',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                // theme color
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Journey to a Beautiful Union Begins Here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                // theme color
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// 👔 Agent Card
                      _EnhancedRoleCard(
                        title: "Agent Portal",
                        subtitle: "Manage leads and match profiles",
                        icon: Icons.business_center_rounded,
                        beginColor: const Color(0xFF6A11CB),
                        endColor: const Color(0xFF2575FC),
                        delay: 0.2,
                        onTap: () =>
                            context.router.push(const AgentLoginRoute()),
                      ),

                      const SizedBox(height: 40),

                      /// ❤️ User Card
                      _EnhancedRoleCard(
                        title: "Member Portal",
                        subtitle: "Find your perfect soulmate",
                        icon: Icons.favorite_rounded,
                        beginColor: const Color(0xFFFF512F),
                        endColor: const Color(0xFFDD2476),
                        delay: 0.4,
                        onTap: () =>
                            context.router.push(const UserLoginRoute()),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔒 Modern Glass Footer
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      border: Border(
                        top: BorderSide(color: Colors.pink.withOpacity(0.1)),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "100% Verified & Secure Profiles",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedRoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color beginColor;
  final Color endColor;
  final double delay;
  final VoidCallback onTap;

  const _EnhancedRoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.beginColor,
    required this.endColor,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_EnhancedRoleCard> createState() => _EnhancedRoleCardState();
}

class _EnhancedRoleCardState extends State<_EnhancedRoleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.97),
        onTapUp: (_) => setState(() => _scale = 1.0),
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.beginColor, widget.endColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.endColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(
                  right: -20,
                  top: -20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
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
