import '../../../../app/custom/custom_widgets/validators.dart';
import '../providers/auth_providers.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/custom/custom_widgets/widgets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;

    if (user == null) {
      if (!mounted) return;
      context.router.replaceAll([ UserLoginRoute()]);
      return;
    }

    try {
      // Reauthenticate user with current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.router.maybePop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message =
              "Please log in again to change your password. For security reasons, this operation requires a recent authentication.";
          break;
        case 'wrong-password':
          message = "The current password you entered is incorrect.";
          break;
        case 'weak-password':
          message =
              "The new password is too weak. Please use a stronger password.";
          break;
        case 'network-request-failed':
          message = "No internet connection. Please check your network.";
          break;
        default:
          message = "Failed to change password: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                "Update Your Password",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter your current password and a new password to update.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 30),
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
                      controller: _currentPasswordController,
                      prefixIcon: Icons.lock,
                      iconColor: theme.colorScheme.primary,
                      label: "Current Password",
                      hint: "Enter your current password",
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _newPasswordController,
                      prefixIcon: Icons.lock_outline,
                      iconColor: theme.colorScheme.primary,
                      label: "New Password",
                      hint: "Enter your new password",
                      obscureText: true,

                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) => Validators.validatePassword(value),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmNewPasswordController,
                      prefixIcon: Icons.lock_reset,
                      iconColor: theme.colorScheme.primary,
                      label: "Confirm New Password",
                      hint: "Confirm your new password",
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: AppButton(
                  text: "Change Password",
                  onPressed: _changePassword,
                ),
              ),
              // change password using email verification
              TextButton(
                onPressed: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  final user = authRepo.currentUser;

                  if (user == null || user.email == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "You must be logged in to reset your password.",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  try {
                    await authRepo.sendPasswordResetEmail(user.email!);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Password reset email sent to ${user.email}. Please check your inbox.",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    String message;
                    switch (e.code) {
                      case 'network-request-failed':
                        message =
                            "No internet connection. Please check your network.";
                        break;
                      case 'user-not-found':
                        message =
                            "No user found with this email. Please ensure you are logged in.";
                        break;
                      default:
                        message = "Failed to send reset email: ${e.message}";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("An unexpected error occurred: $e"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  "Forgot Password? Reset via Email",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
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
