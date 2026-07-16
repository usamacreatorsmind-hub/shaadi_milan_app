import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_labels.dart';
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
      appBar: AppBar(title: Text(AppLabels.resetPassword(context)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ---------------- HEADER ----------------
            Icon(Icons.lock_reset, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              AppLabels.forgotPassword(context),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLabels.resetPasswordSubtitle(context),
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
                    label: AppLabels.email(context),
                    hint: "name@example.com",
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: AppButton(
                      text: AppLabels.sendResetLink(context),
                      onPressed: () async {
                        try {
                          await authRepo.sendPasswordResetEmail(
                            emailCtrl.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLabels.resetLinkSent(context),
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
                              message = AppLabels.userNotFoundWithEmail(context);
                              break;

                            case 'invalid-email':
                              message = AppLabels.invalidEmail(context);
                              break;

                            case 'network-request-failed':
                              message = AppLabels.noInternet(context);
                              break;

                            default:
                              message = AppLabels.unableToSendResetLink(context);
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
                            SnackBar(
                              content: Text(
                                AppLabels.somethingWentWrong(context),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
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
              child: Text(
                AppLabels.changePassword(context),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // ---------------- BACK TO LOGIN ----------------
            TextButton(
              onPressed: () {
                context.router.maybePop();
              },
              child: Text(
                AppLabels.backToLogin(context),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
