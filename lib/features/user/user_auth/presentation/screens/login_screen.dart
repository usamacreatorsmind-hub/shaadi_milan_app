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

  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (emailCtrl.text.isEmpty || pwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final authRepo = ref.watch(authRepositoryProvider);

    try {
      await authRepo.signInWithEmail(emailCtrl.text.trim(), pwCtrl.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 Welcome back! Login successful."),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.router.replace(const AuthWrapperRoute());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = "No account found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        case 'network-request-failed':
          message = "No internet connection.";
          break;
        default:
          message = "Login failed. Try again later.";
          message = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong."),
          behavior: SnackBarBehavior.floating,
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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

              const SizedBox(height: 20),

              Text(
                "Welcome Back!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Login to your account",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- LOGIN CARD ----------------
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
                    AppTextField(
                      controller: emailCtrl,
                      prefixIcon: Icons.email,
                      iconColor: theme.colorScheme.primary,
                      label: "Email",
                      hint: "Enter your email",
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),

                    const SizedBox(height: 12),

                    AppTextField(
                      controller: pwCtrl,
                      prefixIcon: Icons.lock,
                      iconColor: theme.colorScheme.primary,
                      label: "Password",
                      hint: "Enter your password",
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: AppButton(
                        text: isLoading ? "Logging in..." : "Login",
                        onPressed: isLoading ? () {} : () => _login(context),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        context.navigateTo(const RegisterRoute());
                      },
                      child: const Text(
                        "New here? Create an account",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        context.navigateTo(const ResetPasswordRoute());
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    // navigate to education form screen
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
