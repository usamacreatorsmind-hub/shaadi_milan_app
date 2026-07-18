import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/custom/custom_widgets/validators.dart';
import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/app_labels.dart';
import '../providers/auth_providers.dart';

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
      context.router.replaceAll([UserLoginRoute()]);
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
        SnackBar(
          content: Text(AppLabels.passwordChangedSuccessfully(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.router.maybePop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'requires-recent-login':
          message = AppLabels.reauthenticateForSecurity(context);
          break;
        case 'wrong-password':
          message = AppLabels.incorrectCurrentPassword(context);
          break;
        case 'weak-password':
          message = AppLabels.weakNewPassword(context);
          break;
        case 'network-request-failed':
          message = AppLabels.noInternet(context);
          break;
        default:
          message = AppLabels.failedToChangePassword(context, e.message ?? '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppLabels.somethingWentWrong(context)}: $e"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLabels.changePassword(context)),
        centerTitle: true,
      ),
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
                AppLabels.updateYourPassword(context),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppLabels.changePasswordSubtitle(context),
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
                      label: AppLabels.currentPassword(context),
                      hint: AppLabels.passwordHint(context),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLabels.passwordRequired(context);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _newPasswordController,
                      prefixIcon: Icons.lock_outline,
                      iconColor: theme.colorScheme.primary,
                      label: AppLabels.newPassword(context),
                      hint: AppLabels.passwordHint(context),
                      obscureText: true,

                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) =>
                          Validators.validatePassword(context, value),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmNewPasswordController,
                      prefixIcon: Icons.lock_reset,
                      iconColor: theme.colorScheme.primary,
                      label: AppLabels.confirmNewPassword(context),
                      hint: AppLabels.passwordHint(context),
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) => Validators.validateConfirmPassword(
                        context,
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
                  text: AppLabels.changePassword(context),
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
                      SnackBar(
                        content: Text(AppLabels.mustBeLoggedInToReset(context)),
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
                          AppLabels.resetEmailSentTo(context, user.email!),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    String message;
                    switch (e.code) {
                      case 'network-request-failed':
                        message = AppLabels.noInternet(context);
                        break;
                      case 'user-not-found':
                        message = AppLabels.userNotFound(context);
                        break;
                      default:
                        message = AppLabels.failedToSendResetEmail(
                          context,
                          e.message ?? '',
                        );
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
                        content: Text(
                          "${AppLabels.somethingWentWrong(context)}: $e",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Text(
                  AppLabels.forgotPasswordResetViaEmail(context),
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
