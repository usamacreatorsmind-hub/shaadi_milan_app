import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final emailCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authRepo = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------- HEADER ----------------
            Icon(Icons.lock_reset, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              "Forgot your password?",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Enter your email to receive a password reset link.",
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
                    controller: emailCtrl,
                    prefixIcon: Icons.email,
                    iconColor: theme.colorScheme.primary,
                    label: "Email",
                    hint: "Enter your email",
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: AppButton(
                      text: "Send Reset Link",
                      onPressed: () async {
                        try {
                          await authRepo.sendPasswordResetEmail(
                            emailCtrl.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password reset link sent to your email. Please check your inbox.",
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          context.router.maybePop();
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;

                          String message;

                          switch (e.code) {
                            case 'user-not-found':
                              message =
                                  "No account found with this email. Please register first.";
                              break;

                            case 'invalid-email':
                              message = "Please enter a valid email address.";
                              break;

                            case 'network-request-failed':
                              message =
                                  "No internet connection. Please check your network.";
                              break;

                            default:
                              message =
                                  "Unable to send reset link right now. Please try again later.";
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (_) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Something went wrong. Please try again.",
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- RESET BUTTON ----------------
            const SizedBox(height: 20),

            //  going to password   screen
            TextButton(
              onPressed: () {
                context.navigateTo(const ChangePasswordRoute());
              },
              child: const Text(
                "Change Password",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- BACK TO LOGIN ----------------
            TextButton(
              onPressed: () {
                context.router.maybePop();
              },
              child: const Text(
                "Back to Login",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
