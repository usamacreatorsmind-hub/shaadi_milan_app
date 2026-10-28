import 'package:flutter/gestures.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/core/notification/notification_service.dart';
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
        SnackBar(
          content: Text(AppLabels.enterEmailPassword(context)),
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
        SnackBar(
          content: Text(AppLabels.loginSuccessfulAgent(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );

      TextInput.finishAutofillContext(); // ✅ triggers save prompt
      // savetoken to firestore

      final user = authRepo.currentUser;

      if (user != null) {
        NotificationService.saveAdminTokenToFirestore(user.uid);

        context.router.replace(AuthWrapperRoute());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = AppLabels.agentNotFound(context);
          break;
        case 'wrong-password':
          message = AppLabels.incorrectPassword(context);
          break;
        case 'invalid-email':
          message = AppLabels.invalidEmail(context);
          break;
        case 'user-disabled':
          message = AppLabels.accountDisabled(context);
          break;
        case 'network-request-failed':
          message = AppLabels.noInternet(context);
          break;
        default:
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
                  AppLabels.staffLogin(context),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLabels.accessStaffPortal(context),
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
                          label: AppLabels.workEmail(context),
                          hint: AppLabels.workEmailHint(context),
                          keyboardType: TextInputType.emailAddress,
                          iconColor: theme.colorScheme.primary,
                          obscureText: false,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          autofillHints: const [AutofillHints.password],
                          controller: pwCtrl,
                          prefixIcon: Icons.lock_outline_rounded,
                          label: AppLabels.password(context),
                          hint: AppLabels.passwordHint(context),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          iconColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButton(
                            text: isLoading
                                ? AppLabels.loggingIn(context)
                                : AppLabels.login(context),
                            onPressed: () => _login(context),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.navigateTo(ResetPasswordRoute()),
                            child: Text(
                              AppLabels.forgotPassword(context),
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
                      AppLabels.notAStaffMember(context),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => context.router.replace(UserLoginRoute()),
                      child: Text(
                        AppLabels.userLogin(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// 推 Terms & Privacy
                const _TermsPrivacyFooter(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsPrivacyFooter extends StatefulWidget {
  const _TermsPrivacyFooter();

  @override
  State<_TermsPrivacyFooter> createState() => _TermsPrivacyFooterState();
}

class _TermsPrivacyFooterState extends State<_TermsPrivacyFooter> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AppConstants.openUrl(AppConstants.termsAndConditionsUrl);
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        AppConstants.openUrl(AppConstants.privacyPolicyUrl);
      };
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4);
    final linkStyle = TextStyle(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.bold,
      fontSize: 13,
      decoration: TextDecoration.underline,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: '${AppLabels.byContinuingAgree(context)} '),
            TextSpan(
              text: AppLabels.termsAndConditions(context),
              style: linkStyle,
              recognizer: _termsRecognizer,
            ),
            TextSpan(text: ' ${AppLabels.andLabel(context)} '),
            TextSpan(
              text: AppLabels.privacyPolicy(context),
              style: linkStyle,
              recognizer: _privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}
