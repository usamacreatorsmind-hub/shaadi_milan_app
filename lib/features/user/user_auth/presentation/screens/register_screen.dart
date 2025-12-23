import 'dart:ui';

import 'package:arvika_marriage_bureau/app/custom/custom_widgets/widgets.dart';

import '../controllers/auth_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final agentIdCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    pwCtrl.dispose();
    agentIdCtrl.dispose();
    super.dispose();
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
                Icon(
                  Icons.favorite,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  "Create Your Account",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Start your journey towards a happy marriage",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- CARD ----------------
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppTextField(
                        obscureText: false,
                        keyboardType: TextInputType.name,

                        controller: nameCtrl,
                        prefixIcon: Icons.person,
                        iconColor: theme.colorScheme.primary,
                        label: "Full Name",
                        hint: "Enter your full name",
                      ),

                      const SizedBox(height: 16),
                      AppTextField(
                        controller: phoneCtrl,
                        obscureText: false,
                        prefixIcon: Icons.phone,
                        iconColor: theme.colorScheme.primary,
                        label: "Phone Number",
                        hint: "Enter your phone number",
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: emailCtrl,
                        obscureText: false,

                        prefixIcon: Icons.email,
                        iconColor: theme.colorScheme.primary,
                        label: "Email",
                        hint: "Enter your email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: pwCtrl,
                        prefixIcon: Icons.lock,
                        iconColor: theme.colorScheme.primary,
                        label: "Password",
                        hint: "Enter your password",
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: agentIdCtrl,
                        prefixIcon: Icons.badge,
                        iconColor: theme.colorScheme.primary,
                        label: "Agent ID",
                        hint: "Enter Agent ID",
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- REGISTER BUTTON ----------------
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: AppButton(
                    text: 'Create Account',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

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
                            content: Text(
                              "🎉 Account created successfully! Welcome aboard.",
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        context.router.popUntilRoot();
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;

                        String message;

                        switch (e.code) {
                          case 'weak-password':
                            message =
                                "Your password is too weak. Please use at least 8 characters.";
                            break;

                          case 'email-already-in-use':
                            message =
                                "This email is already registered. Try logging in instead.";
                            break;

                          case 'invalid-email':
                            message =
                                "Please enter a valid email address (example@gmail.com).";
                            break;

                          case 'operation-not-allowed':
                            message =
                                "Registration is temporarily unavailable. Please try later.";
                            break;

                          case 'network-request-failed':
                            message =
                                "No internet connection. Please check your network.";
                            break;

                          default:
                            message =
                                "Something went wrong. Please try again in a moment.";
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------- FOOTER ----------------
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
        ),
      ),
    );
  }
}
