import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadi_milan/core/constants/app_constants.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/core/notification/notification_service.dart';

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
  final phoneCtrl = TextEditingController();

  bool isLoading = false;
  bool isOtpMode = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    pwCtrl.dispose();
    phoneCtrl.dispose();
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
      final credential = await authRepo.signInWithEmail(
        emailCtrl.text.trim(),
        pwCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLabels.loginSuccessful(context)),
          behavior: SnackBarBehavior.floating,
        ),
      );

      TextInput.finishAutofillContext(); // ✅ triggers save prompt

      final user = credential.user;
      if (user != null) {
        // Invalidate auth state to ensure latest data is loaded
        ref.invalidate(authStateProvider);
        NotificationService.saveUserTokenToFirestore(user.uid);

        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        context.router.replace(AuthWrapperRoute());
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = AppLabels.userNotFoundWithEmail(context);
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
          message = AppLabels.loginFailedTryAgain(context);
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

  Future<void> _sendOtp(BuildContext context) async {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);

    try {
      final fullPhone = phone.startsWith('91') && phone.length > 10 ? phone : '91$phone';
      final res = await authRepo.sendMSG91OTP(fullPhone);

      if (!mounted) return;

      if (res['success'] == true) {
        context.navigateTo(OtpVerificationRoute(phoneNumber: fullPhone));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? "Failed to send OTP"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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
                  AppLabels.welcome(context),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLabels.welcomeSubtitle(context),
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isOtpMode = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !isOtpMode ? theme.colorScheme.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Password",
                                        style: TextStyle(
                                          color: !isOtpMode ? Colors.white : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isOtpMode = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isOtpMode ? theme.colorScheme.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "OTP Login",
                                        style: TextStyle(
                                          color: isOtpMode ? Colors.white : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!isOtpMode) ...[
                          AppTextField(
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                            iconColor: theme.colorScheme.primary,
                            obscureText: false,
                            controller: emailCtrl,
                            prefixIcon: Icons.email_outlined,
                            label: AppLabels.email(context),
                            hint: AppLabels.emailHint(context),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          AppTextField(
                            autofillHints: const [AutofillHints.password],
                            iconColor: theme.colorScheme.primary,
                            obscureText: true,
                            controller: pwCtrl,
                            prefixIcon: Icons.lock_open_rounded,
                            label: AppLabels.password(context),
                            hint: AppLabels.passwordHint(context),
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.navigateTo(const ResetPasswordRoute()),
                              child: Text(
                                AppLabels.forgotPassword(context),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          AppTextField(
                            iconColor: theme.colorScheme.primary,
                            obscureText: false,
                            controller: phoneCtrl,
                            prefixIcon: Icons.phone_android_rounded,
                            label: "Mobile Number",
                            hint: "Enter 10-digit mobile number",
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButton(
                            text: isLoading
                                ? (isOtpMode ? "Sending OTP..." : AppLabels.loggingIn(context))
                                : (isOtpMode ? "Send OTP" : AppLabels.login(context)),
                            onPressed: () => isOtpMode ? _sendOtp(context) : _login(context),
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
                      AppLabels.dontHaveAccount(context),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => context.navigateTo(UserRegisterRoute()),
                      child: Text(
                        AppLabels.createNewProfile(context),
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

                /// 📄 Terms & Privacy
                _TermsPrivacyFooter(),

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
