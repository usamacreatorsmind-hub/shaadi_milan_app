import 'package:arvika_marriage_bureau/app/custom/custom_widgets/contact_us_screen.dart';
import 'package:arvika_marriage_bureau/app/custom/custom_widgets/privacy_policy_route.dart';
import 'package:arvika_marriage_bureau/app/custom/custom_widgets/terms_and_conditions_route.dart';
import 'package:arvika_marriage_bureau/core/enums/enum.dart';
import 'package:arvika_marriage_bureau/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/address_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/cultural_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/education_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/employee_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/family_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/identity_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_profile_view_model.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/physical_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/user_state.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/about_us_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/screens/user_status_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/agent_contact_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/widgets/MyProfileDetailScreen.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_order_history_screen.dart';
import 'package:arvika_marriage_bureau/features/user/user_razorpay/presentation/screens/user_payment_success_screen.dart';

import '../../features/agent/presentation/screens/agent_dashboard_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/user/user_auth/presentation/screens/agent_profile_verify_screen.dart';
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
import '../../features/user/user_auth/presentation/screens/auth_wrapper.dart';
import '../../features/user/user_auth/presentation/screens/change_password_screen.dart';
import '../../features/user/user_auth/presentation/screens/login_screen.dart';
import '../../features/user/user_auth/presentation/screens/register_screen.dart';
import '../../features/user/user_auth/presentation/screens/reset_password_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    // ================= ROOT =================
    AutoRoute(page: SplashRoute.page, initial: true),

    AutoRoute(page: AuthWrapperRoute.page),

    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),

    AutoRoute(page: ContactUsRoute.page),
    AutoRoute(page: PrivacyPolicyRoute.page),
    AutoRoute(page: TermsAndConditionsRoute.page),
    // ================= USER MAIN SHELL (BOTTOM NAV) =================
    AutoRoute(
      page: UserMainShellRoute.page,
      children: [
        AutoRoute(page: UserHomeRoute.page, initial: true),

        AutoRoute(page: UserWishListRoute.page),

        AutoRoute(page: UserChatRoute.page),
        AutoRoute(page: UserProfileRoute.page),
      ],
    ),

    // ================= USER FLOW =================
    AutoRoute(page: MatrimonyFormFlowRoute.page),
    AutoRoute(page: UserIdentityFormRoute.page),
    AutoRoute(page: UserPhysicalFormRoute.page),
    AutoRoute(page: UserCultureFormRoute.page),
    AutoRoute(page: UserEducationFormRoute.page),
    AutoRoute(page: UserEmploymentFormRoute.page),
    AutoRoute(page: UserFamilyFormRoute.page),
    AutoRoute(page: UserAddressFormRoute.page),
    AutoRoute(page: UserBiodataCheckRoute.page),
    AutoRoute(page: UserDetailRoute.page),
    AutoRoute(page: UserImageFormRoute.page),
    AutoRoute(page: SearchRoute.page),
    AutoRoute(page: UserNotificationRoute.page),
    AutoRoute(page: MyProfileDetailRoute.page),
    AutoRoute(page: MyProfileRoute.page),
    AutoRoute(page: UserPaymentRoute.page),
    AutoRoute(page: ResetPasswordRoute.page),
    AutoRoute(page: ChangePasswordRoute.page),
    AutoRoute(page: UserStatusRoute.page),
    AutoRoute(page: UserPaymentOrderHistoryRoute.page),
    AutoRoute(page: UserPaymentSuccessRoute.page),

    // ================= AGENT =================
    AutoRoute(page: AgentDashboardRoute.page),
    AutoRoute(page: AgentProfileVerifyRoute.page),
    AutoRoute(page: AgentContactRoute.page),

    // ================= ABOUT US =================
    AutoRoute(page: AboutUsRoute.page),
  ];
}
