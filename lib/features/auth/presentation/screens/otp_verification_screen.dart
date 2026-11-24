import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/core/notification/notification_service.dart';
import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  bool isLoading = false;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = pinController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a valid OTP"), behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);

    try {
      final res = await authRepo.verifyMSG91OTP(widget.phoneNumber, otp);

      if (!mounted) return;

      if (res['success'] == true && res['verified'] == true) {
        if (res['registered'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(AppLabels.loginSuccessful(context)), behavior: SnackBarBehavior.floating));
          ref.invalidate(authStateProvider);
          final currentUser = authRepo.currentUser;
          if (currentUser != null) {
            NotificationService.saveUserTokenToFirestore(currentUser.uid);
          }
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          context.router.replaceAll([const AuthWrapperRoute()]);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("This phone number is not registered. Please sign up."), behavior: SnackBarBehavior.floating),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res['message'] ?? "Invalid OTP. Please try again."), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final res = await authRepo.sendMSG91OTP(widget.phoneNumber);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP resent successfully"), behavior: SnackBarBehavior.floating));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res['message'] ?? "Failed to resend OTP"), behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black87, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: theme.colorScheme.primary, width: 2)),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE0E6), Colors.white]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(onPressed: () => context.router.back(), icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
                ),
                const SizedBox(height: 40),
                Text(
                  "Verify OTP",
                  style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  "We have sent a verification code to\n${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 50),
                Pinput(
                  length: 4,
                  controller: pinController,
                  focusNode: focusNode,
                  androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) => _verifyOtp(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AppButton(text: isLoading ? "Verifying..." : "Verify & Login", onPressed: _verifyOtp),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ", style: TextStyle(color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: isLoading ? null : _resendOtp,
                      child: Text(
                        "Resend",
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
