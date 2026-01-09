import 'package:arvika_marriage_bureau/app/custom/custom_widgets/contact_us_screen.dart';
import 'package:arvika_marriage_bureau/app/custom/custom_widgets/privacy_policy_route.dart';
import 'package:arvika_marriage_bureau/app/custom/custom_widgets/terms_and_conditions_route.dart';
import 'package:arvika_marriage_bureau/app/router/agent_guard.dart';
import 'package:arvika_marriage_bureau/app/router/auth_guard.dart';
import 'package:arvika_marriage_bureau/app/router/role_wrapper.dart';
import 'package:arvika_marriage_bureau/app/router/user_guard.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agen_home_screen.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:arvika_marriage_bureau/features/agent/agent_app/presentation/screens/agent_main_shell_screen.dart';
import 'package:arvika_marriage_bureau/features/auth/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/address_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/cultural_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/education_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/employee_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/family_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/identity_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/physical_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/about_us_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_status_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/agent_contact_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/MyProfileDetailScreen.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_order_history_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_success_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/agent/agent_app/presentation/screens/agent_dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/user/user_app/presentation/screens/metrimony_flow_screen.dart';
import '../../features/user/user_app/presentation/screens/search_screen.dart';
import '../../features/user/user_app/presentation/screens/my_profile_screen.dart';
import '../../features/user/user_app/presentation/screens/user_address_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_biodata_check_screen.dart';
import '../../features/user/user_app/presentation/screens/user_chat_screen.dart';
import '../../features/user/user_app/presentation/screens/user_culture_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_details_screen.dart';
import '../../features/user/user_app/presentation/screens/user_education_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_employement_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_family_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_home_screen.dart';
import '../../features/user/user_app/presentation/screens/user_identity_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_image_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_main_shell.dart';
import '../../features/user/user_app/presentation/screens/user_wishlist_screen.dart';
import '../../features/user/user_app/presentation/screens/user_notification_screen.dart';
import '../../features/user/user_razorpay/presentation/screens/user_payment_screen.dart';
import '../../features/user/user_app/presentation/screens/user_physical_form_screen.dart';
import '../../features/user/user_app/presentation/screens/user_profile_screen.dart';
// Unified AuthWrapperScreen
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/user_login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/user_register_screen.dart';
import '../../features/auth/presentation/screens/agent_login_screen.dart';
import '../../features/agent/agent_app/presentation/screens/agen_profile.screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'agent_router.dart';
import 'user_router.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  final Ref ref;
  AppRouter(this.ref);

  @override
  List<AutoRoute> get routes => [
    // ================= ROOT =================
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: AuthWrapperRoute.page), // Unified authentication wrapper
    // ================= AUTH & PUBLIC =================
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: UserLoginRoute.page), // For Users
    AutoRoute(page: AgentLoginRoute.page), // For Agents
    AutoRoute(page: UserRegisterRoute.page),
    AutoRoute(page: AboutUsRoute.page),
    AutoRoute(page: ContactUsRoute.page),
    AutoRoute(page: PrivacyPolicyRoute.page),
    AutoRoute(page: TermsAndConditionsRoute.page),

    // ================= USER ROUTES =================
    ...UserRouter.routes(ref),

    // ================= AGENT ROUTES =================
    ...AgentRouter.routes(ref),
  ];
}
