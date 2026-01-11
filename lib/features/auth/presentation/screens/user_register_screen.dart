import '../providers/auth_providers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';

@RoutePage()
class UserRegisterScreen extends ConsumerStatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  ConsumerState<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends ConsumerState<UserRegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final confirmPwCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    pwCtrl.dispose();
    confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        pwCtrl.text.isEmpty ||
        confirmPwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (pwCtrl.text != confirmPwCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final authRepo = ref.watch(authRepositoryProvider);

    try {
      await authRepo.signUpUserWithEmail(
        email: emailCtrl.text.trim(),
        password: pwCtrl.text.trim(),
        fullName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        agentId: '',
        wishlists: [],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final user = authRepo.currentUser;
      if (user != null) {
        context.router.replace(AuthWrapperRoute());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = "An account with this email already exists.";
          break;
        case 'invalid-email':
          message = "Invalid email address.";
          break;
        case 'weak-password':
          message = "Password is too weak.";
          break;
        case 'network-request-failed':
          message = "No internet connection.";
          break;
        default:
          message = "Registration failed. Try again later.";
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
      // Matching the consistent premium background
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
                /// 🔙 Header with Back Button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.router.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 20),

                Text(
                  "Create Account",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Join Arvika Marriage Bureau today",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),

                const SizedBox(height: 30),

                /// 📝 Registration Card
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
                  child: Column(
                    children: [
                      AppTextField(
                        iconColor: theme.colorScheme.primary,
                        obscureText: false,
                        controller: nameCtrl,
                        prefixIcon: Icons.person_outline_rounded,
                        label: "Full Name",
                        hint: "John Doe",
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: emailCtrl,
                        prefixIcon: Icons.alternate_email_rounded,
                        label: "Email",
                        hint: "example@mail.com",
                        keyboardType: TextInputType.emailAddress,
                        iconColor: theme.colorScheme.primary,
                        obscureText: false,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: phoneCtrl,
                        prefixIcon: Icons.phone_android_rounded,
                        label: "Phone",
                        hint: "+1 234 567 890",
                        keyboardType: TextInputType.phone,
                        obscureText: false,
                        iconColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        obscureText: true,
                        iconColor: theme.colorScheme.primary,

                        controller: pwCtrl,
                        prefixIcon: Icons.lock_outline_rounded,
                        label: "Password",
                        hint: "••••••••",
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: confirmPwCtrl,
                        prefixIcon: Icons.verified_user_outlined,
                        label: "Confirm Password",
                        hint: "••••••••",
                        obscureText: true,

                        keyboardType: TextInputType.visiblePassword,
                        iconColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => _register(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Create Profile",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// 🔗 Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a member?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => context.router.back(),
                      child: const Text(
                        "Login Now",
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
