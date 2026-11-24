import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../app/custom/custom_widgets/widgets.dart';
import '../providers/auth_providers.dart';

@RoutePage()
class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends ConsumerState<ForgotPasswordOtpScreen> {
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final newPwCtrl = TextEditingController();
  final confirmPwCtrl = TextEditingController();

  String? _verificationId;
  bool _isOtpSent = false;
  bool _isVerified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    otpCtrl.dispose();
    newPwCtrl.dispose();
    confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      _showSnackBar("Please enter a valid 10-digit phone number");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      
      // Check if user exists with this phone
      final exists = await authRepo.checkPhoneAlreadyRegistered(phone);
      if (!exists) {
        _showSnackBar("This phone number is not registered");
        setState(() => _isLoading = false);
        return;
      }

      await authRepo.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          _showSnackBar("OTP sent successfully");
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          _showSnackBar(e.message ?? "Verification failed");
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpCtrl.text.trim();
    if (otp.isEmpty || _verificationId == null) {
      _showSnackBar("Please enter OTP");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithPhoneCredential(_verificationId!, otp);
      
      setState(() {
        _isVerified = true;
        _isLoading = false;
      });
      _showSnackBar("Phone verified successfully");
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Invalid OTP. Please try again.");
    }
  }

  Future<void> _resetPassword() async {
    final newPw = newPwCtrl.text.trim();
    final confirmPw = confirmPwCtrl.text.trim();

    if (newPw.isEmpty || confirmPw.isEmpty) {
      _showSnackBar("Please fill all password fields");
      return;
    }

    if (newPw != confirmPw) {
      _showSnackBar("Passwords do not match");
      return;
    }

    if (newPw.length < 6) {
      _showSnackBar("Password must be at least 6 characters long");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.updatePassword(newPw);
      
      await authRepo.signOut(); // Sign out the temporary phone session

      if (!mounted) return;
      _showSnackBar("Password reset successfully. Please login with your new password.");
      context.router.popUntilRoot();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: theme.colorScheme.primary, width: 2)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password via OTP"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            Icon(Icons.vibration_rounded, size: 80, color: theme.primaryColor),
            const SizedBox(height: 20),
            Text(
              _isVerified 
                  ? "Set New Password" 
                  : (_isOtpSent ? "Verify OTP" : "Enter Registered Phone"),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            if (!_isOtpSent && !_isVerified) ...[
              AppTextField(
                controller: phoneCtrl,
                prefixIcon: Icons.phone_android_rounded,
                label: "Phone Number",
                hint: "10-digit mobile number",
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                obscureText: false,
                iconColor: theme.primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  text: _isLoading ? "Sending OTP..." : "SEND OTP",
                  onPressed: _isLoading ? () {} : () { _sendOtp(); },
                ),
              ),
            ],

            if (_isOtpSent && !_isVerified) ...[
              Text(
                "OTP sent to +91 ${phoneCtrl.text}",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Pinput(
                length: 6,
                controller: otpCtrl,
                androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
                autofillHints: const [AutofillHints.oneTimeCode],
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) => _verifyOtp(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  text: _isLoading ? "Verifying..." : "VERIFY OTP",
                  onPressed: _isLoading ? () {} : () { _verifyOtp(); },
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : () { _sendOtp(); },
                child: const Text("Resend OTP"),
              ),
            ],

            if (_isVerified) ...[
              AppTextField(
                controller: newPwCtrl,
                prefixIcon: Icons.lock_outline_rounded,
                label: "New Password",
                hint: "Min 6 characters",
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                iconColor: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: confirmPwCtrl,
                prefixIcon: Icons.verified_user_outlined,
                label: "Confirm Password",
                hint: "Re-enter new password",
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                iconColor: theme.primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  text: _isLoading ? "Resetting..." : "RESET PASSWORD",
                  onPressed: _isLoading ? () {} : () { _resetPassword(); },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
