import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/custom/custom_widgets/validators.dart';
import '../../../../../app/custom/custom_widgets/widgets.dart';
import '../../../../../app/providers/global_providers.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../core/constants/app_labels.dart';
import '../../../../../core/enums/enum.dart';
import '../../../../translitration/models/bilingual_value.dart';
import '../../../../translitration/widgets/bilingual_text_field.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../user/user_app/presentation/controllers/metrimony_profile_controller.dart';

@RoutePage()
class AgentAddClientScreen extends ConsumerStatefulWidget {
  const AgentAddClientScreen({super.key});

  @override
  ConsumerState<AgentAddClientScreen> createState() => _AgentAddClientScreenState();
}

class _AgentAddClientScreenState extends ConsumerState<AgentAddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameHiCtrl = TextEditingController();
  final nameEnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String? selectedGender;
  bool isLoading = false;
  bool skipProfileSetup = false;

  @override
  void dispose() {
    nameHiCtrl.dispose();
    nameEnCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _createClient() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select gender")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Check if email or phone already exists
      final emailExists = await authRepo.checkUserExists(phone: "", email: emailCtrl.text.trim());
      final phoneExists = await authRepo.checkPhoneAlreadyRegistered(phoneCtrl.text.trim());

      if (emailExists) throw Exception("Email already registered");
      if (phoneExists) throw Exception("Phone number already registered");

      final authState = ref.read(authStateProvider).value;
      final agent = authState?.fold((agent) => agent, (user) => null);

      if (agent == null) throw Exception("Only agents can add clients");

      // 1. Create Firebase Auth account for client (Using secondary instance to avoid Agent logout)
      final FirebaseApp secondaryApp = await Firebase.initializeApp(name: 'ClientRegistrationApp', options: Firebase.app().options);

      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final UserCredential userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final String clientUid = userCredential.user!.uid;

      // Clean up secondary app
      await secondaryApp.delete();

      final genderBilingual = selectedGender == "male"
          ? BilingualValue(en: "Male", hi: "पुरुष")
          : BilingualValue(en: "Female", hi: "महिला");

      // 2. Create basic user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(clientUid).set({
        'uid': clientUid,
        'fullName': {'hi': nameHiCtrl.text.trim(), 'en': nameEnCtrl.text.trim()},
        'gender': genderBilingual.toMap(),
        'email': emailCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'agentId': agent.uid,
        'role': 'user',
        'userType': '',
        'profileImageUrl': '',
        'profileStatus': 'active',
        'isProfileCreated': false,
        'isAgentLedRegistration': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // 3. Initialize Matrimony Profile
      await ref.read(metrimonyControllerProvider.notifier).createEmptyMatrimonyProfile(clientUid, agent.agentId);

      // 4. Set target user ID for the flow (Override)
      ref.read(targetUserIdOverrideProvider.notifier).state = clientUid;

      // 5. Initialize flow controller
      ref.read(metrimonyControllerProvider.notifier).startAgentLedRegistration(clientUid);

      if (!mounted) return;

      // 6. Navigate based on skip preference
      if (skipProfileSetup) {
        // Clear override and go back to dashboard
        ref.read(targetUserIdOverrideProvider.notifier).state = null;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Client account created successfully (Profile skipped)")));
        context.router.replaceAll([AgentMainShellRoute(agentId: agent.uid)]);
      } else {
        // Start the 9-page flow
        context.router.push(const MatrimonyFormFlowRoute());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Client")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Client Basics", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Fill in the basic details to start the matrimony profile registration.", style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),

              BilingualTextField(
                controller: nameHiCtrl,
                englishController: nameEnCtrl,
                label: "Client Full Name",
                hint: "Enter client name",
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: emailCtrl,
                label: "Email Address",
                hint: "client@example.com",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
                validator: (v) => Validators.validateEmail(context, v),
                iconColor: Colors.red,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: phoneCtrl,
                label: "Phone Number",
                hint: "10-digit mobile number",
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                maxLimit: 10,
                obscureText: false,
                validator: (v) => Validators.validatePhoneNumber(context, v),
                iconColor: Colors.red,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordCtrl,
                label: "Account Password",
                hint: "Create a password for client",
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (v) => Validators.validatePassword(context, v),
                iconColor: theme.primaryColor,
              ),

              const SizedBox(height: 24),
              const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _genderOption("male", "Male", Icons.male),
                  const SizedBox(width: 16),
                  _genderOption("female", "Female", Icons.female),
                ],
              ),

              const SizedBox(height: 32),

              // ⏭ Skip Profile Toggle
              const SizedBox(height: 40),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: AppButton(text: "Start 9-Page Registration", onPressed: _createClient),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderOption(String value, String label, IconData icon) {
    final isSelected = selectedGender == value;
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedGender = value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? theme.primaryColor : Colors.grey.shade300, width: 2),
            boxShadow: isSelected
                ? [BoxShadow(color: theme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade800, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
