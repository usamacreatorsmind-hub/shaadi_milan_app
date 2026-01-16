import 'package:flutter/services.dart';

import '../providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';

@RoutePage()
class AgentLoginScreen extends ConsumerStatefulWidget {
  const AgentLoginScreen({super.key});

  @override
  ConsumerState<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends ConsumerState<AgentLoginScreen> {
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
      await authRepo.signInAgentWithEmail(
        emailCtrl.text.trim(),
        pwCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Welcome Agent! Login successful."),
          behavior: SnackBarBehavior.floating,
        ),
      );

      TextInput.finishAutofillContext(); // ✅ triggers save prompt

      final user = authRepo.currentUser;
      if (user != null) {
        context.router.replace(AuthWrapperRoute());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = "No agent account found with this email.";
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
      // Matching the gradient from the selection screen
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
                const SizedBox(height: 20),

                /// 🔙 Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.router.back(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),

                /// 🏢 Animated Header Area
                const SizedBox(height: 40),

                Text(
                  "Agent Login",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Access your agent portal",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),

                const SizedBox(height: 40),

                /// 💳 Login Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 24,
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
                          controller: emailCtrl,
                          prefixIcon: Icons.alternate_email_rounded,
                          label: "Work Email",
                          hint: "agent@arvika.com",
                          keyboardType: TextInputType.emailAddress,
                          iconColor: theme.colorScheme.primary,
                          obscureText: false,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          autofillHints: const [AutofillHints.password],
                          controller: pwCtrl,
                          prefixIcon: Icons.lock_outline_rounded,
                          label: "Password",
                          hint: "••••••••",
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          iconColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButton(
                            text: isLoading ? "Logging in..." : "Login",
                            onPressed: () => _login(context),
                          ),
                        ),

                        const SizedBox(height: 12),

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

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔄 Switch to User Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not an agent?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.router.replace(const UserLoginRoute()),
                      child: const Text(
                        "User Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
