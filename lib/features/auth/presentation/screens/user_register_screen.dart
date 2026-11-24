import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:shadi_milan/app/custom/custom_widgets/validators.dart';
import 'package:shadi_milan/core/constants/app_labels.dart';
import 'package:shadi_milan/core/notification/notification_service.dart';
import 'package:shadi_milan/features/translitration/models/bilingual_value.dart';
import 'package:shadi_milan/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import 'package:sizer/sizer.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';
import '../../../translitration/widgets/bilingual_text_field.dart';
import '../providers/auth_providers.dart';

enum Gender { male, female }

enum _RegisterStage { phoneEntry, otpVerify, basicDetails }

final genderProvider = StateProvider.autoDispose<String?>((ref) => null);

@RoutePage()
class UserRegisterScreen extends ConsumerStatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  ConsumerState<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends ConsumerState<UserRegisterScreen> {
  final nameCtrl = TextEditingController();
  final englishNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  final confirmPwCtrl = TextEditingController();
  final agentIdCtrl = TextEditingController();

  _RegisterStage _stage = _RegisterStage.phoneEntry;
  bool isLoading = false;
  String _verifiedPhone10 = '';

  @override
  void dispose() {
    nameCtrl.dispose();
    englishNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    otpCtrl.dispose();
    pwCtrl.dispose();
    confirmPwCtrl.dispose();
    agentIdCtrl.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _isPhoneAlreadyTaken(String phone10) async {
    final authRepo = ref.read(authRepositoryProvider);
    final variants = [phone10, '+91$phone10', '91$phone10'];
    for (final v in variants) {
      final exists = await authRepo.checkPhoneAlreadyRegistered(v);
      if (exists == true) return true;
    }
    return false;
  }

  Future<void> _sendOtp() async {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    final phone10 = phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');

    if (phone10.length != 10) {
      _showSnackBar(
        isHindi
            ? 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें'
            : 'Please enter a valid 10-digit mobile number',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final alreadyTaken = await _isPhoneAlreadyTaken(phone10);
      if (!mounted) return;
      if (alreadyTaken) {
        _showSnackBar(AppLabels.phoneAlreadyRegistered(context));
        return;
      }

      final authRepo = ref.read(authRepositoryProvider);
      final res = await authRepo.sendMSG91OTP('91$phone10');
      if (!mounted) return;

      if (res['success'] == true) {
        otpCtrl.clear();
        setState(() => _stage = _RegisterStage.otpVerify);
        _showSnackBar(
          isHindi
              ? '+91 $phone10 पर OTP भेजा गया है'
              : 'OTP sent to +91 $phone10',
        );
      } else {
        _showSnackBar(
          res['message']?.toString() ??
              (isHindi ? 'OTP भेजने में विफल' : 'Failed to send OTP'),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    final phone10 = phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    final otp = otpCtrl.text.trim();

    if (otp.length < 4) {
      _showSnackBar(
        isHindi
            ? 'कृपया 4 अंकों का मान्य OTP दर्ज करें'
            : 'Please enter a valid 4-digit OTP',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final res = await authRepo.verifyMSG91OTP('91$phone10', otp);
      if (!mounted) return;

      if (res['success'] == true && res['verified'] == true) {
        if (res['registered'] == true) {
          // Account already existed with this phone; sign out temporary session and inform user
          await authRepo.signOut();
          if (!mounted) return;
          _showSnackBar(AppLabels.phoneAlreadyRegistered(context));
          setState(() => _stage = _RegisterStage.phoneEntry);
          return;
        }

        setState(() {
          _verifiedPhone10 = phone10;
          phoneCtrl.text = phone10;
          _stage = _RegisterStage.basicDetails;
        });
        _showSnackBar(
          isHindi
              ? 'मोबाइल नंबर सत्यापित हो गया! अब बेसिक जानकारी भरें।'
              : 'Mobile number verified! Now fill your basic details.',
          backgroundColor: Colors.green.shade700,
        );
      } else {
        _showSnackBar(
          res['message']?.toString() ??
              (isHindi
                  ? 'अमान्य OTP। कृपया पुनः प्रयास करें।'
                  : 'Invalid OTP. Please try again.'),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _register(BuildContext context) async {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    String? agentUid;

    if (_verifiedPhone10.length != 10) {
      _showSnackBar(
        isHindi
            ? 'कृपया पहले अपना मोबाइल नंबर OTP से सत्यापित करें'
            : 'Please verify your mobile number with OTP first',
      );
      setState(() => _stage = _RegisterStage.phoneEntry);
      return;
    }

    if (nameCtrl.text.trim().isEmpty ||
        englishNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        pwCtrl.text.trim().isEmpty ||
        confirmPwCtrl.text.trim().isEmpty) {
      _showSnackBar(AppLabels.fillAllFields(context));
      return;
    }

    final selectedGender = ref.read(genderProvider);
    if (selectedGender == null || selectedGender.isEmpty) {
      _showSnackBar(
        isHindi ? 'कृपया अपना लिंग (Gender) चुनें' : 'Please select your gender',
      );
      return;
    }

    if (pwCtrl.text != confirmPwCtrl.text) {
      _showSnackBar(AppLabels.passwordsDoNotMatch(context));
      return;
    }

    setState(() => isLoading = true);

    final authRepo = ref.read(authRepositoryProvider);
    final agentId = agentIdCtrl.text.trim();
    final firestore = ref.read(agentFirestoreDsProvider);
    bool agentExists = false;

    if (agentId.isNotEmpty) {
      try {
        agentExists = await firestore.checkAgentExists(agentId: agentId);
        if (agentExists) {
          agentUid = await firestore.fetchAgentDocIdByAgentId(agentId: agentId);
        }
      } catch (e) {
        if (!mounted) return;
        _showSnackBar(AppLabels.errorCheckingStaffId(context, e.toString()));
        setState(() => isLoading = false);
        return;
      }
    }

    if (agentId.isNotEmpty && !agentExists) {
      if (!mounted) return;
      _showSnackBar(AppLabels.staffIdNotExists(context));
      setState(() => isLoading = false);
      return;
    }

    final isPhoneRegistered = await _isPhoneAlreadyTaken(_verifiedPhone10);
    final isEmailRegistered = await authRepo.checkUserExists(
      phone: '',
      email: emailCtrl.text.trim(),
    );

    if (isEmailRegistered) {
      if (!mounted) return;
      _showSnackBar(AppLabels.emailAlreadyRegistered(context));
      setState(() => isLoading = false);
      return;
    }

    if (isPhoneRegistered) {
      if (!mounted) return;
      _showSnackBar(AppLabels.phoneAlreadyRegistered(context));
      setState(() => isLoading = false);
      return;
    }

    try {
      final genderBilingual = selectedGender == 'male'
          ? BilingualValue(en: 'Male', hi: 'पुरुष')
          : BilingualValue(en: 'Female', hi: 'महिला');

      await authRepo.signUpUserWithEmail(
        email: emailCtrl.text.trim(),
        password: pwCtrl.text.trim(),
        fullName: BilingualValue(
          en: englishNameCtrl.text.trim(),
          hi: nameCtrl.text.trim(),
        ),
        phone: _verifiedPhone10,
        gender: genderBilingual,
        agentId: agentUid ?? '',
      );

      if (!mounted) return;

      _showSnackBar(AppLabels.accountCreatedSuccessfully(context));
      TextInput.finishAutofillContext();

      final user = authRepo.currentUser;
      if (user != null) {
        ref.invalidate(authStateProvider);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        NotificationService.saveUserTokenToFirestore(user.uid);

        // Route to Step 2: View Profiles vs Complete Your Profile
        context.router.replaceAll([const OnboardingChoiceRoute()]);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = AppLabels.accountAlreadyExists(context);
          break;
        case 'invalid-email':
          message = AppLabels.invalidEmail(context);
          break;
        case 'weak-password':
          message = AppLabels.passwordTooWeak(context);
          break;
        case 'network-request-failed':
          message = AppLabels.noInternet(context);
          break;
        default:
          message = e.message ?? e.toString();
      }
      _showSnackBar(message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(AppLabels.somethingWentWrong(context));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    final isBasicStep = _stage == _RegisterStage.basicDetails;

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
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_stage == _RegisterStage.otpVerify) {
                        setState(() => _stage = _RegisterStage.phoneEntry);
                      } else {
                        context.router.back();
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  AppLabels.createAccount(context),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  AppLabels.joinToday(context),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),

              // Step indicator: 1. Verify Mobile -> 2. Basic Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _StepPill(
                        number: '1',
                        label: isHindi ? 'मोबाइल सत्यापन' : 'Verify Mobile',
                        isActive: !isBasicStep,
                        isDone: isBasicStep,
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 2,
                      color: isBasicStep
                          ? theme.primaryColor
                          : Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _StepPill(
                        number: '2',
                        label: isHindi ? 'बेसिक जानकारी' : 'Basic Details',
                        isActive: isBasicStep,
                        isDone: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _buildStageContent(context, theme, isHindi),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLabels.alreadyAMember(context),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () => context.router.back(),
                    child: Text(
                      AppLabels.loginNow(context),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent(
    BuildContext context,
    ThemeData theme,
    bool isHindi,
  ) {
    switch (_stage) {
      case _RegisterStage.phoneEntry:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isHindi
                  ? 'अपना मोबाइल नंबर दर्ज करें'
                  : 'Enter your mobile number',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'अकाउंट बनाने से पहले हम OTP द्वारा आपका मोबाइल नंबर सत्यापित करेंगे।'
                  : 'We will send a 4-digit OTP to verify your mobile number before creating your account.',
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              autofillHints: const [AutofillHints.telephoneNumber],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) =>
                  Validators.validatePhoneNumber(context, value),
              showWordCount: true,
              counterType: CounterType.characters,
              controller: phoneCtrl,
              maxLimit: 10,
              prefixIcon: Icons.phone_android_rounded,
              label: AppLabels.phone(context),
              hint: AppLabels.phoneHint(context),
              keyboardType: TextInputType.phone,
              obscureText: false,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: AppButton(
                text: isLoading
                    ? (isHindi ? 'OTP भेजा जा रहा है...' : 'Sending OTP...')
                    : (isHindi ? 'OTP भेजें' : 'Send OTP'),
                onPressed: isLoading ? () {} : _sendOtp,
              ),
            ),
          ],
        );

      case _RegisterStage.otpVerify:
        final defaultPinTheme = PinTheme(
          width: 56,
          height: 56,
          textStyle: const TextStyle(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        );
        final focusedPinTheme = defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: theme.colorScheme.primary, width: 2),
          ),
        );

        return Column(
          children: [
            Text(
              isHindi ? 'OTP सत्यापित करें' : 'Verify OTP',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? '+91 ${phoneCtrl.text.trim()} पर भेजा गया 4 अंकों का कोड दर्ज करें'
                  : 'Enter the 4-digit code sent to +91 ${phoneCtrl.text.trim()}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Pinput(
              length: 4,
              controller: otpCtrl,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              autofillHints: const [AutofillHints.oneTimeCode],
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (_) {
                if (!isLoading) _verifyOtp();
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: AppButton(
                text: isLoading
                    ? (isHindi ? 'सत्यापन हो रहा है...' : 'Verifying...')
                    : (isHindi ? 'OTP सत्यापित करें' : 'Verify OTP'),
                onPressed: isLoading ? () {} : _verifyOtp,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => setState(() => _stage = _RegisterStage.phoneEntry),
                  child: Text(isHindi ? 'नंबर बदलें' : 'Change Number'),
                ),
                TextButton(
                  onPressed: isLoading ? null : _sendOtp,
                  child: Text(
                    isHindi ? 'OTP पुनः भेजें' : 'Resend OTP',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case _RegisterStage.basicDetails:
        return AutofillGroup(
          child: Column(
            children: [
              // Verified Phone Display Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Colors.green.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isHindi
                                ? 'सत्यापित मोबाइल नंबर'
                                : 'Verified Mobile Number',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            '+91 $_verifiedPhone10',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _verifiedPhone10 = '';
                                otpCtrl.clear();
                                _stage = _RegisterStage.phoneEntry;
                              });
                            },
                      child: Text(isHindi ? 'बदलें' : 'Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              BilingualTextField(
                controller: nameCtrl,
                englishController: englishNameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                label: AppLabels.fullName(context),
                hint: AppLabels.fullNameHint(context),
              ),
              const SizedBox(height: 16),
              AppTextField(
                autofillHints: const [AutofillHints.email],
                controller: emailCtrl,
                prefixIcon: Icons.alternate_email_rounded,
                label: AppLabels.email(context),
                hint: AppLabels.emailHint(context),
                keyboardType: TextInputType.emailAddress,
                iconColor: theme.colorScheme.primary,
                obscureText: false,
              ),
              const SizedBox(height: 16),
              AppTextField(
                autofillHints: const [AutofillHints.newPassword],
                obscureText: true,
                iconColor: theme.colorScheme.primary,
                validator: (value) =>
                    Validators.validatePassword(context, value),
                controller: pwCtrl,
                prefixIcon: Icons.lock_outline_rounded,
                label: AppLabels.password(context),
                hint: AppLabels.passwordHint(context),
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                autofillHints: const [AutofillHints.newPassword],
                controller: confirmPwCtrl,
                obscureText: true,
                iconColor: theme.colorScheme.primary,
                validator: (value) => Validators.validateConfirmPassword(
                  context,
                  value,
                  pwCtrl.text,
                ),
                prefixIcon: Icons.verified_user_outlined,
                label: AppLabels.confirmPassword(context),
                hint: AppLabels.passwordHint(context),
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: agentIdCtrl,
                prefixIcon: Icons.badge_outlined,
                label: AppLabels.staffId(context),
                hint: AppLabels.optional(context),
                obscureText: false,
                keyboardType: TextInputType.text,
                iconColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  genderCard(context, AppLabels.male(context), 'male', ref),
                  const Spacer(),
                  genderCard(context, AppLabels.female(context), 'female', ref),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AppButton(
                  text: isLoading
                      ? AppLabels.registering(context)
                      : AppLabels.register(context),
                  onPressed: isLoading ? () {} : () => _register(context),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget genderCard(
    BuildContext context,
    String title,
    String genderValue,
    WidgetRef ref,
  ) {
    final selectedGender = ref.watch(genderProvider);
    final theme = Theme.of(context);
    final isSelected = selectedGender == genderValue;

    return InkWell(
      onTap: () {
        ref.read(genderProvider.notifier).state = genderValue;
      },
      child: Container(
        height: 50,
        width: 30.w,
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : const Color.fromARGB(255, 218, 45, 45),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color:
                  isSelected ? theme.colorScheme.onPrimary : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String number;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepPill({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isDone
        ? Colors.green.shade600
        : isActive
            ? theme.primaryColor
            : Colors.grey.shade200;
    final fgColor = (isDone || isActive) ? Colors.white : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.primaryColor.withValues(alpha: 0.1)
            : isDone
                ? Colors.green.shade50
                : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? Colors.green.shade300
              : isActive
                  ? theme.primaryColor
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: bgColor,
            child: isDone
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : Text(
                    number,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDone
                    ? Colors.green.shade800
                    : isActive
                        ? theme.primaryColor
                        : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
