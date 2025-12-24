import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';
import '../controllers/auth_controller.dart';

@RoutePage()
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final agentIdCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    pwCtrl.dispose();
    agentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(
            nameCtrl.text.trim(),
            emailCtrl.text.trim(),
            pwCtrl.text.trim(),
            agentIdCtrl.text.trim(),
            phoneCtrl.text.trim(),
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Account created successfully! Welcome aboard."),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.router.popUntilRoot();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'weak-password':
          message = "Password must be at least 8 characters long.";
          break;
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;
        case 'operation-not-allowed':
          message = "Registration is currently disabled.";
          break;
        case 'network-request-failed':
          message = "No internet connection.";
          break;
        default:
          message = "Registration failed. Please try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------------- HEADER ----------------
                // ---------------- LOGO ----------------
                Material(
                  shape: const CircleBorder(),
                  elevation: 6,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.25,
                    backgroundImage: const AssetImage('assets/images/logo.png'),
                    backgroundColor: Colors.transparent,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Create Your Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Join us and find your perfect match!",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 5),

                // ---------------- REGISTER CARD ----------------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      AppTextField(
                        controller: nameCtrl,
                        prefixIcon: Icons.person,
                        iconColor: theme.colorScheme.primary,
                        label: "Full Name",
                        hint: "Enter your full name",
                        keyboardType: TextInputType.name,
                        obscureText: false,
                      ),

                      SizedBox(height: 10),
                      AppTextField(
                        controller: phoneCtrl,
                        prefixIcon: Icons.phone,
                        iconColor: theme.colorScheme.primary,
                        label: "Phone Number",
                        hint: "Enter your phone number",
                        keyboardType: TextInputType.phone,
                        obscureText: false,
                      ),

                      SizedBox(height: 10),
                      AppTextField(
                        controller: emailCtrl,
                        prefixIcon: Icons.email,
                        iconColor: theme.colorScheme.primary,
                        label: "Email",
                        hint: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                      ),

                      SizedBox(height: 10),
                      AppTextField(
                        controller: pwCtrl,
                        prefixIcon: Icons.lock,
                        iconColor: theme.colorScheme.primary,
                        label: "Password",
                        hint: "Enter your password",
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),

                      SizedBox(height: 10),
                      AppTextField(
                        controller: agentIdCtrl,
                        prefixIcon: Icons.badge,
                        iconColor: theme.colorScheme.primary,
                        label: "Agent ID",
                        hint: "Enter Agent ID",
                        keyboardType: TextInputType.text,
                        obscureText: false,
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: AppButton(
                          text: isLoading
                              ? "Creating Account..."
                              : "Create Account",
                          onPressed: isLoading
                              ? () {}
                              : () => _register(context),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.router.pop();
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- REGISTER BUTTON ----------------

                // ---------------- FOOTER ----------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
