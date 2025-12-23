import 'package:arvika_marriage_bureau/core/env/app_env_config.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authRepo = ref.read(authRepositoryProvider);
    final env = AppEnvConfig.instance;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(env.environment.name),
              // Text(
              //   'Firebase Project ID from Provider: ${ref.watch(appEnvProvider).firebaseProjectId}',
              // ),

              // ---------------- HEADER ----------------
              Icon(Icons.favorite, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                "Welcome Back 💍",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Login to continue your journey",
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
                    const SizedBox(height: 16),

                    AppTextField(
                      controller: pwCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      iconColor: theme.colorScheme.primary,
                      label: "Password",
                      hint: "Enter your password",
                      keyboardType: TextInputType.visiblePassword,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- LOGIN BUTTON ----------------
              SizedBox(
                width: double.infinity,
                height: 55,
                child: AppButton(
                  text: "Login",
                  onPressed: () async {
                    try {
                      await authRepo.signInWithEmail(
                        emailCtrl.text.trim(),
                        pwCtrl.text.trim(),
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🎉 Welcome back! Login successful."),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Navigate to home
                      context.router.replace(const AuthWrapperRoute());
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;

                      String message;

                      switch (e.code) {
                        case 'user-not-found':
                          message =
                              "No account found with this email. Please register first.";
                          break;

                        case 'wrong-password':
                          message = "Incorrect password. Please try again.";
                          break;

                        case 'invalid-email':
                          message = "Please enter a valid email address.";
                          break;

                        case 'user-disabled':
                          message =
                              "This account has been disabled. Contact support.";
                          break;

                        case 'network-request-failed':
                          message =
                              "No internet connection. Please check your network.";
                          break;

                        default:
                          message =
                              "Unable to login right now. Please try again later.";
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

              const SizedBox(height: 20),

              // ---------------- REGISTER LINK ----------------
              TextButton(
                onPressed: () {
                  context.navigateTo(const RegisterRoute());
                },
                child: const Text(
                  "New here? Create an account",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              // ---------------- FORGOT PASSWORD ----------------
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality

                  context.navigateTo(const ResetPasswordRoute());
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
