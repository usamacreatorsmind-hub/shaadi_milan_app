import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class UserLoginScreen extends ConsumerStatefulWidget {
  const UserLoginScreen({super.key});

  @override
  ConsumerState<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends ConsumerState<UserLoginScreen> {
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
      final credential = await authRepo.signInWithEmail(
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

      TextInput.finishAutofillContext(); // ✅ triggers save prompt

      final user = credential.user;
      if (user != null) {
        // Invalidate auth state to ensure latest data is loaded
        ref.invalidate(authStateProvider);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        context.router.replace(AuthWrapperRoute());
      }
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0E6), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// 🔙 Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.router.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // only name
                Text(
                  "Welcome,",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue your journey",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),

                const SizedBox(height: 40),

                /// 💳 Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          136,
                          135,
                          135,
                        ).withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        AppTextField(
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],

                          iconColor: theme.colorScheme.primary,
                          obscureText: false,

                          controller: emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          label: "Email Address",
                          hint: "name@example.com",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          autofillHints: const [AutofillHints.password],

                          iconColor: theme.colorScheme.primary,
                          obscureText: true,

                          controller: pwCtrl,
                          prefixIcon: Icons.lock_open_rounded,
                          label: "Password",
                          hint: "••••••••",

                          keyboardType: TextInputType.visiblePassword,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.navigateTo(const ResetPasswordRoute()),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButton(
                            text: isLoading ? "Logging in..." : "Login",
                            onPressed: () => _login(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                /// 🆕 Registration Prompt
                Column(
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () =>
                          context.navigateTo(const UserRegisterRoute()),
                      child: Text(
                        "Create a New Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
