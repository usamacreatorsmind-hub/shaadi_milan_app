import 'package:arvika_marriage_bureau/app/custom/custom_widgets/validators.dart';
import 'package:arvika_marriage_bureau/core/notification/notification_service.dart';
import 'package:arvika_marriage_bureau/features/auth/data/repositories_impl/data_source/firebase_auth_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/datasources/firebase/agent_firestore_ds.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_firestore.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/notifier/payment_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sizer/sizer.dart';

import '../providers/auth_providers.dart';

import '../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../app/router/app_router.dart';

enum Gender { male, female }

final genderProvider = StateProvider.autoDispose<String?>((ref) => null);

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
  final agentIdCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    pwCtrl.dispose();
    confirmPwCtrl.dispose();
    agentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _register(BuildContext context) async {
    String? agentUid;
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        agentIdCtrl.text.isEmpty ||
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

    // 2️⃣ check if agent exists
    // 2️⃣ check if agent exists

    final agentId = agentIdCtrl.text.trim();
    final firestore = ref.read(agentFirestoreDsProvider);
    bool agentExists = false;

    // check if phone is registered

    if (agentId.isNotEmpty) {
      try {
        agentExists = await firestore.checkAgentExists(agentId: agentId);
        if (agentExists) {
          agentUid = await firestore.fetchAgentDocIdByAgentId(agentId: agentId);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking agent ID: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => isLoading = false);
        return;
      }
    }

    if (agentId.isNotEmpty && !agentExists) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Agent ID does not exist. Please check the ID or leave it blank.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    final isPhoneRegistered = await authRepo.checkPhoneAlreadyRegistered(
      phoneCtrl.text.trim(),
    );

    final isEmailRegistered = await authRepo.checkUserExists(
      phone: "",
      email: emailCtrl.text.trim(),
    );

    if (isEmailRegistered) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This email is already registered."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    if (isPhoneRegistered) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This phone number is already registered."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      await authRepo.signUpUserWithEmail(
        email: emailCtrl.text.trim(),
        password: pwCtrl.text.trim(),
        fullName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        gender: ref.read(genderProvider) ?? "",

        agentId: agentUid ?? "",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          behavior: SnackBarBehavior.floating,
        ),
      );

      TextInput.finishAutofillContext(); // ✅ triggers save prompt

      final user = authRepo.currentUser;
      if (user != null) {
        // Invalidate auth state to ensure latest data is loaded
        ref.invalidate(authStateProvider);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        NotificationService.saveUserTokenToFirestore(user.uid);

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
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        AppTextField(
                          autofillHints: const [AutofillHints.name],
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
                          autofillHints: const [AutofillHints.email],
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
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) =>
                              Validators.validatePhoneNumber(value),
                          showWordCount: true,

                          counterType: CounterType.characters,

                          controller: phoneCtrl,
                          maxLimit: 10,

                          prefixIcon: Icons.phone_android_rounded,
                          label: "Phone",
                          hint: "1234 567 890",
                          keyboardType: TextInputType.phone,
                          obscureText: false,
                          iconColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          autofillHints: const [AutofillHints.newPassword],
                          obscureText: true,
                          iconColor: theme.colorScheme.primary,
                          validator: (value) =>
                              Validators.validatePassword(value),

                          controller: pwCtrl,
                          prefixIcon: Icons.lock_outline_rounded,
                          label: "Password",
                          hint: "••••••••",
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          autofillHints: const [AutofillHints.newPassword],
                          controller: confirmPwCtrl,

                          obscureText: true,
                          iconColor: theme.colorScheme.primary,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                pwCtrl.text,
                              ),

                          prefixIcon: Icons.verified_user_outlined,
                          label: "Confirm Password",
                          hint: "••••••••",

                          keyboardType: TextInputType.visiblePassword,
                        ),

                        // create gender
                        const SizedBox(height: 16),
                        AppTextField(
                          autofillHints: const [AutofillHints.newPassword],
                          controller: agentIdCtrl,
                          prefixIcon: Icons.verified_user_outlined,
                          label: "Agent Id  ",
                          hint: "",
                          obscureText: false,
                          keyboardType: TextInputType.visiblePassword,
                          iconColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            genderCard(context, "Male", "male", ref),
                            Spacer(),
                            genderCard(context, "Female", "female", ref),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: AppButton(
                            text: isLoading ? "Registering..." : "Register",
                            onPressed: () => _register(context),
                          ),
                        ),
                      ],
                    ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
