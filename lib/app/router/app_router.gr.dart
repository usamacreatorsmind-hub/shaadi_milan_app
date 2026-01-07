// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AboutUsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AboutUsScreen(),
      );
    },
    AgentContactRoute.name: (routeData) {
      final args = routeData.argsAs<AgentContactRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentContactScreen(key: args.key, agentId: args.agentId),
      );
    },
    AgentDashboardRoute.name: (routeData) {
      final args = routeData.argsAs<AgentDashboardRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentDashboardScreen(uid: args.uid, key: args.key),
      );
    },
    AgentProfileVerifyRoute.name: (routeData) {
      final args = routeData.argsAs<AgentProfileVerifyRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentProfileVerifyScreen(key: args.key, agentId: args.agentId),
      );
    },
    AuthWrapperRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AuthWrapperScreen(),
      );
    },
    ChangePasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChangePasswordScreen(),
      );
    },
    ContactUsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContactUsScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MatrimonyFormFlowRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MatrimonyFormFlowScreen(),
      );
    },
    MyProfileDetailRoute.name: (routeData) {
      final args = routeData.argsAs<MyProfileDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MyProfileDetailScreen(key: args.key, user: args.user),
      );
    },
    MyProfileRoute.name: (routeData) {
      final args = routeData.argsAs<MyProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MyProfileScreen(key: args.key, uid: args.uid),
      );
    },
    OnboardingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OnboardingScreen(),
      );
    },
    PrivacyPolicyRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PrivacyPolicyScreen(),
      );
    },
    RegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RegisterScreen(),
      );
    },
    ResetPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ResetPasswordScreen(),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TermsAndConditionsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TermsAndConditionsScreen(),
      );
    },
    UserAddressFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserAddressFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserAddressFormScreen(
          key: args.key,
          mode: args.mode,
          existingAddressProfile: args.existingAddressProfile,
        ),
      );
    },
    UserBiodataCheckRoute.name: (routeData) {
      final args = routeData.argsAs<UserBiodataCheckRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserBiodataCheckScreen(key: args.key, isAgreed: args.isAgreed),
      );
    },
    UserChatRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserChatScreen(),
      );
    },
    UserCultureFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserCultureFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserCultureFormScreen(
          key: args.key,
          mode: args.mode,
          existingCulturalProfile: args.existingCulturalProfile,
        ),
      );
    },
    UserDetailRoute.name: (routeData) {
      final args = routeData.argsAs<UserDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserDetailScreen(key: args.key, uid: args.uid),
      );
    },
    UserEducationFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserEducationFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserEducationFormScreen(
          key: args.key,
          mode: args.mode,
          existingEducationProfile: args.existingEducationProfile,
        ),
      );
    },
    UserEmploymentFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserEmploymentFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserEmploymentFormScreen(
          key: args.key,
          mode: args.mode,
          existingEmploymentProfile: args.existingEmploymentProfile,
        ),
      );
    },
    UserFamilyFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserFamilyFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserFamilyFormScreen(
          key: args.key,
          mode: args.mode,
          existingFamilyProfile: args.existingFamilyProfile,
        ),
      );
    },
    UserHomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserHomeScreen(),
      );
    },
    UserIdentityFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserIdentityFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserIdentityFormScreen(
          key: args.key,
          mode: args.mode,
          existingIdentityProfile: args.existingIdentityProfile,
        ),
      );
    },
    UserImageFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserImageFormScreen(),
      );
    },
    UserMainShellRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserMainShellScreen(),
      );
    },
    UserNotificationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserNotificationScreen(),
      );
    },
    UserPaymentOrderHistoryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserPaymentOrderHistoryScreen(),
      );
    },
    UserPaymentRoute.name: (routeData) {
      final args = routeData.argsAs<UserPaymentRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserPaymentScreen(
          key: args.key,
          metrimonyProfileViewModel: args.metrimonyProfileViewModel,
        ),
      );
    },
    UserPaymentSuccessRoute.name: (routeData) {
      final args = routeData.argsAs<UserPaymentSuccessRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserPaymentSuccessScreen(key: args.key, user: args.user),
      );
    },
    UserPhysicalFormRoute.name: (routeData) {
      final args = routeData.argsAs<UserPhysicalFormRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserPhysicalFormScreen(
          key: args.key,
          mode: args.mode,
          existingPhysicalProfile: args.existingPhysicalProfile,
        ),
      );
    },
    UserProfileRoute.name: (routeData) {
      final args = routeData.argsAs<UserProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserProfileScreen(key: args.key, userId: args.userId),
      );
    },
    UserStatusRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserStatusScreen(),
      );
    },
    UserWishListRoute.name: (routeData) {
      final args = routeData.argsAs<UserWishListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserWishListScreen(key: args.key, userId: args.userId),
      );
    },
  };
}

/// generated route for
/// [AboutUsScreen]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
    : super(AboutUsRoute.name, initialChildren: children);

  static const String name = 'AboutUsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AgentContactScreen]
class AgentContactRoute extends PageRouteInfo<AgentContactRouteArgs> {
  AgentContactRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
         AgentContactRoute.name,
         args: AgentContactRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentContactRoute';

  static const PageInfo<AgentContactRouteArgs> page =
      PageInfo<AgentContactRouteArgs>(name);
}

class AgentContactRouteArgs {
  const AgentContactRouteArgs({this.key, required this.agentId});

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'AgentContactRouteArgs{key: $key, agentId: $agentId}';
  }
}

/// generated route for
/// [AgentDashboardScreen]
class AgentDashboardRoute extends PageRouteInfo<AgentDashboardRouteArgs> {
  AgentDashboardRoute({
    required String uid,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AgentDashboardRoute.name,
         args: AgentDashboardRouteArgs(uid: uid, key: key),
         initialChildren: children,
       );

  static const String name = 'AgentDashboardRoute';

  static const PageInfo<AgentDashboardRouteArgs> page =
      PageInfo<AgentDashboardRouteArgs>(name);
}

class AgentDashboardRouteArgs {
  const AgentDashboardRouteArgs({required this.uid, this.key});

  final String uid;

  final Key? key;

  @override
  String toString() {
    return 'AgentDashboardRouteArgs{uid: $uid, key: $key}';
  }
}

/// generated route for
/// [AgentProfileVerifyScreen]
class AgentProfileVerifyRoute
    extends PageRouteInfo<AgentProfileVerifyRouteArgs> {
  AgentProfileVerifyRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
         AgentProfileVerifyRoute.name,
         args: AgentProfileVerifyRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentProfileVerifyRoute';

  static const PageInfo<AgentProfileVerifyRouteArgs> page =
      PageInfo<AgentProfileVerifyRouteArgs>(name);
}

class AgentProfileVerifyRouteArgs {
  const AgentProfileVerifyRouteArgs({this.key, required this.agentId});

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'AgentProfileVerifyRouteArgs{key: $key, agentId: $agentId}';
  }
}

/// generated route for
/// [AuthWrapperScreen]
class AuthWrapperRoute extends PageRouteInfo<void> {
  const AuthWrapperRoute({List<PageRouteInfo>? children})
    : super(AuthWrapperRoute.name, initialChildren: children);

  static const String name = 'AuthWrapperRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContactUsScreen]
class ContactUsRoute extends PageRouteInfo<void> {
  const ContactUsRoute({List<PageRouteInfo>? children})
    : super(ContactUsRoute.name, initialChildren: children);

  static const String name = 'ContactUsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MatrimonyFormFlowScreen]
class MatrimonyFormFlowRoute extends PageRouteInfo<void> {
  const MatrimonyFormFlowRoute({List<PageRouteInfo>? children})
    : super(MatrimonyFormFlowRoute.name, initialChildren: children);

  static const String name = 'MatrimonyFormFlowRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MyProfileDetailScreen]
class MyProfileDetailRoute extends PageRouteInfo<MyProfileDetailRouteArgs> {
  MyProfileDetailRoute({
    Key? key,
    required AppUser user,
    List<PageRouteInfo>? children,
  }) : super(
         MyProfileDetailRoute.name,
         args: MyProfileDetailRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'MyProfileDetailRoute';

  static const PageInfo<MyProfileDetailRouteArgs> page =
      PageInfo<MyProfileDetailRouteArgs>(name);
}

class MyProfileDetailRouteArgs {
  const MyProfileDetailRouteArgs({this.key, required this.user});

  final Key? key;

  final AppUser user;

  @override
  String toString() {
    return 'MyProfileDetailRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [MyProfileScreen]
class MyProfileRoute extends PageRouteInfo<MyProfileRouteArgs> {
  MyProfileRoute({Key? key, required String uid, List<PageRouteInfo>? children})
    : super(
        MyProfileRoute.name,
        args: MyProfileRouteArgs(key: key, uid: uid),
        initialChildren: children,
      );

  static const String name = 'MyProfileRoute';

  static const PageInfo<MyProfileRouteArgs> page = PageInfo<MyProfileRouteArgs>(
    name,
  );
}

class MyProfileRouteArgs {
  const MyProfileRouteArgs({this.key, required this.uid});

  final Key? key;

  final String uid;

  @override
  String toString() {
    return 'MyProfileRouteArgs{key: $key, uid: $uid}';
  }
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TermsAndConditionsScreen]
class TermsAndConditionsRoute extends PageRouteInfo<void> {
  const TermsAndConditionsRoute({List<PageRouteInfo>? children})
    : super(TermsAndConditionsRoute.name, initialChildren: children);

  static const String name = 'TermsAndConditionsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserAddressFormScreen]
class UserAddressFormRoute extends PageRouteInfo<UserAddressFormRouteArgs> {
  UserAddressFormRoute({
    Key? key,
    required FormMode mode,
    required AddressProfile? existingAddressProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserAddressFormRoute.name,
         args: UserAddressFormRouteArgs(
           key: key,
           mode: mode,
           existingAddressProfile: existingAddressProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserAddressFormRoute';

  static const PageInfo<UserAddressFormRouteArgs> page =
      PageInfo<UserAddressFormRouteArgs>(name);
}

class UserAddressFormRouteArgs {
  const UserAddressFormRouteArgs({
    this.key,
    required this.mode,
    required this.existingAddressProfile,
  });

  final Key? key;

  final FormMode mode;

  final AddressProfile? existingAddressProfile;

  @override
  String toString() {
    return 'UserAddressFormRouteArgs{key: $key, mode: $mode, existingAddressProfile: $existingAddressProfile}';
  }
}

/// generated route for
/// [UserBiodataCheckScreen]
class UserBiodataCheckRoute extends PageRouteInfo<UserBiodataCheckRouteArgs> {
  UserBiodataCheckRoute({
    Key? key,
    required bool isAgreed,
    List<PageRouteInfo>? children,
  }) : super(
         UserBiodataCheckRoute.name,
         args: UserBiodataCheckRouteArgs(key: key, isAgreed: isAgreed),
         initialChildren: children,
       );

  static const String name = 'UserBiodataCheckRoute';

  static const PageInfo<UserBiodataCheckRouteArgs> page =
      PageInfo<UserBiodataCheckRouteArgs>(name);
}

class UserBiodataCheckRouteArgs {
  const UserBiodataCheckRouteArgs({this.key, required this.isAgreed});

  final Key? key;

  final bool isAgreed;

  @override
  String toString() {
    return 'UserBiodataCheckRouteArgs{key: $key, isAgreed: $isAgreed}';
  }
}

/// generated route for
/// [UserChatScreen]
class UserChatRoute extends PageRouteInfo<void> {
  const UserChatRoute({List<PageRouteInfo>? children})
    : super(UserChatRoute.name, initialChildren: children);

  static const String name = 'UserChatRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserCultureFormScreen]
class UserCultureFormRoute extends PageRouteInfo<UserCultureFormRouteArgs> {
  UserCultureFormRoute({
    Key? key,
    required FormMode mode,
    CulturalProfile? existingCulturalProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserCultureFormRoute.name,
         args: UserCultureFormRouteArgs(
           key: key,
           mode: mode,
           existingCulturalProfile: existingCulturalProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserCultureFormRoute';

  static const PageInfo<UserCultureFormRouteArgs> page =
      PageInfo<UserCultureFormRouteArgs>(name);
}

class UserCultureFormRouteArgs {
  const UserCultureFormRouteArgs({
    this.key,
    required this.mode,
    this.existingCulturalProfile,
  });

  final Key? key;

  final FormMode mode;

  final CulturalProfile? existingCulturalProfile;

  @override
  String toString() {
    return 'UserCultureFormRouteArgs{key: $key, mode: $mode, existingCulturalProfile: $existingCulturalProfile}';
  }
}

/// generated route for
/// [UserDetailScreen]
class UserDetailRoute extends PageRouteInfo<UserDetailRouteArgs> {
  UserDetailRoute({
    Key? key,
    required String uid,
    List<PageRouteInfo>? children,
  }) : super(
         UserDetailRoute.name,
         args: UserDetailRouteArgs(key: key, uid: uid),
         initialChildren: children,
       );

  static const String name = 'UserDetailRoute';

  static const PageInfo<UserDetailRouteArgs> page =
      PageInfo<UserDetailRouteArgs>(name);
}

class UserDetailRouteArgs {
  const UserDetailRouteArgs({this.key, required this.uid});

  final Key? key;

  final String uid;

  @override
  String toString() {
    return 'UserDetailRouteArgs{key: $key, uid: $uid}';
  }
}

/// generated route for
/// [UserEducationFormScreen]
class UserEducationFormRoute extends PageRouteInfo<UserEducationFormRouteArgs> {
  UserEducationFormRoute({
    Key? key,
    required FormMode mode,
    required EducationProfile? existingEducationProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserEducationFormRoute.name,
         args: UserEducationFormRouteArgs(
           key: key,
           mode: mode,
           existingEducationProfile: existingEducationProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserEducationFormRoute';

  static const PageInfo<UserEducationFormRouteArgs> page =
      PageInfo<UserEducationFormRouteArgs>(name);
}

class UserEducationFormRouteArgs {
  const UserEducationFormRouteArgs({
    this.key,
    required this.mode,
    required this.existingEducationProfile,
  });

  final Key? key;

  final FormMode mode;

  final EducationProfile? existingEducationProfile;

  @override
  String toString() {
    return 'UserEducationFormRouteArgs{key: $key, mode: $mode, existingEducationProfile: $existingEducationProfile}';
  }
}

/// generated route for
/// [UserEmploymentFormScreen]
class UserEmploymentFormRoute
    extends PageRouteInfo<UserEmploymentFormRouteArgs> {
  UserEmploymentFormRoute({
    Key? key,
    required FormMode mode,
    required EmploymentProfile? existingEmploymentProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserEmploymentFormRoute.name,
         args: UserEmploymentFormRouteArgs(
           key: key,
           mode: mode,
           existingEmploymentProfile: existingEmploymentProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserEmploymentFormRoute';

  static const PageInfo<UserEmploymentFormRouteArgs> page =
      PageInfo<UserEmploymentFormRouteArgs>(name);
}

class UserEmploymentFormRouteArgs {
  const UserEmploymentFormRouteArgs({
    this.key,
    required this.mode,
    required this.existingEmploymentProfile,
  });

  final Key? key;

  final FormMode mode;

  final EmploymentProfile? existingEmploymentProfile;

  @override
  String toString() {
    return 'UserEmploymentFormRouteArgs{key: $key, mode: $mode, existingEmploymentProfile: $existingEmploymentProfile}';
  }
}

/// generated route for
/// [UserFamilyFormScreen]
class UserFamilyFormRoute extends PageRouteInfo<UserFamilyFormRouteArgs> {
  UserFamilyFormRoute({
    Key? key,
    required FormMode mode,
    required FamilyProfile? existingFamilyProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserFamilyFormRoute.name,
         args: UserFamilyFormRouteArgs(
           key: key,
           mode: mode,
           existingFamilyProfile: existingFamilyProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserFamilyFormRoute';

  static const PageInfo<UserFamilyFormRouteArgs> page =
      PageInfo<UserFamilyFormRouteArgs>(name);
}

class UserFamilyFormRouteArgs {
  const UserFamilyFormRouteArgs({
    this.key,
    required this.mode,
    required this.existingFamilyProfile,
  });

  final Key? key;

  final FormMode mode;

  final FamilyProfile? existingFamilyProfile;

  @override
  String toString() {
    return 'UserFamilyFormRouteArgs{key: $key, mode: $mode, existingFamilyProfile: $existingFamilyProfile}';
  }
}

/// generated route for
/// [UserHomeScreen]
class UserHomeRoute extends PageRouteInfo<void> {
  const UserHomeRoute({List<PageRouteInfo>? children})
    : super(UserHomeRoute.name, initialChildren: children);

  static const String name = 'UserHomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserIdentityFormScreen]
class UserIdentityFormRoute extends PageRouteInfo<UserIdentityFormRouteArgs> {
  UserIdentityFormRoute({
    Key? key,
    required FormMode mode,
    IdentityProfile? existingIdentityProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserIdentityFormRoute.name,
         args: UserIdentityFormRouteArgs(
           key: key,
           mode: mode,
           existingIdentityProfile: existingIdentityProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserIdentityFormRoute';

  static const PageInfo<UserIdentityFormRouteArgs> page =
      PageInfo<UserIdentityFormRouteArgs>(name);
}

class UserIdentityFormRouteArgs {
  const UserIdentityFormRouteArgs({
    this.key,
    required this.mode,
    this.existingIdentityProfile,
  });

  final Key? key;

  final FormMode mode;

  final IdentityProfile? existingIdentityProfile;

  @override
  String toString() {
    return 'UserIdentityFormRouteArgs{key: $key, mode: $mode, existingIdentityProfile: $existingIdentityProfile}';
  }
}

/// generated route for
/// [UserImageFormScreen]
class UserImageFormRoute extends PageRouteInfo<void> {
  const UserImageFormRoute({List<PageRouteInfo>? children})
    : super(UserImageFormRoute.name, initialChildren: children);

  static const String name = 'UserImageFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserMainShellScreen]
class UserMainShellRoute extends PageRouteInfo<void> {
  const UserMainShellRoute({List<PageRouteInfo>? children})
    : super(UserMainShellRoute.name, initialChildren: children);

  static const String name = 'UserMainShellRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserNotificationScreen]
class UserNotificationRoute extends PageRouteInfo<void> {
  const UserNotificationRoute({List<PageRouteInfo>? children})
    : super(UserNotificationRoute.name, initialChildren: children);

  static const String name = 'UserNotificationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserPaymentOrderHistoryScreen]
class UserPaymentOrderHistoryRoute extends PageRouteInfo<void> {
  const UserPaymentOrderHistoryRoute({List<PageRouteInfo>? children})
    : super(UserPaymentOrderHistoryRoute.name, initialChildren: children);

  static const String name = 'UserPaymentOrderHistoryRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserPaymentScreen]
class UserPaymentRoute extends PageRouteInfo<UserPaymentRouteArgs> {
  UserPaymentRoute({
    Key? key,
    required MetrimonyProfileViewModel metrimonyProfileViewModel,
    List<PageRouteInfo>? children,
  }) : super(
         UserPaymentRoute.name,
         args: UserPaymentRouteArgs(
           key: key,
           metrimonyProfileViewModel: metrimonyProfileViewModel,
         ),
         initialChildren: children,
       );

  static const String name = 'UserPaymentRoute';

  static const PageInfo<UserPaymentRouteArgs> page =
      PageInfo<UserPaymentRouteArgs>(name);
}

class UserPaymentRouteArgs {
  const UserPaymentRouteArgs({
    this.key,
    required this.metrimonyProfileViewModel,
  });

  final Key? key;

  final MetrimonyProfileViewModel metrimonyProfileViewModel;

  @override
  String toString() {
    return 'UserPaymentRouteArgs{key: $key, metrimonyProfileViewModel: $metrimonyProfileViewModel}';
  }
}

/// generated route for
/// [UserPaymentSuccessScreen]
class UserPaymentSuccessRoute
    extends PageRouteInfo<UserPaymentSuccessRouteArgs> {
  UserPaymentSuccessRoute({
    Key? key,
    required AppUser user,
    List<PageRouteInfo>? children,
  }) : super(
         UserPaymentSuccessRoute.name,
         args: UserPaymentSuccessRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'UserPaymentSuccessRoute';

  static const PageInfo<UserPaymentSuccessRouteArgs> page =
      PageInfo<UserPaymentSuccessRouteArgs>(name);
}

class UserPaymentSuccessRouteArgs {
  const UserPaymentSuccessRouteArgs({this.key, required this.user});

  final Key? key;

  final AppUser user;

  @override
  String toString() {
    return 'UserPaymentSuccessRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [UserPhysicalFormScreen]
class UserPhysicalFormRoute extends PageRouteInfo<UserPhysicalFormRouteArgs> {
  UserPhysicalFormRoute({
    Key? key,
    required FormMode mode,
    required PhysicalProfile? existingPhysicalProfile,
    List<PageRouteInfo>? children,
  }) : super(
         UserPhysicalFormRoute.name,
         args: UserPhysicalFormRouteArgs(
           key: key,
           mode: mode,
           existingPhysicalProfile: existingPhysicalProfile,
         ),
         initialChildren: children,
       );

  static const String name = 'UserPhysicalFormRoute';

  static const PageInfo<UserPhysicalFormRouteArgs> page =
      PageInfo<UserPhysicalFormRouteArgs>(name);
}

class UserPhysicalFormRouteArgs {
  const UserPhysicalFormRouteArgs({
    this.key,
    required this.mode,
    required this.existingPhysicalProfile,
  });

  final Key? key;

  final FormMode mode;

  final PhysicalProfile? existingPhysicalProfile;

  @override
  String toString() {
    return 'UserPhysicalFormRouteArgs{key: $key, mode: $mode, existingPhysicalProfile: $existingPhysicalProfile}';
  }
}

/// generated route for
/// [UserProfileScreen]
class UserProfileRoute extends PageRouteInfo<UserProfileRouteArgs> {
  UserProfileRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         UserProfileRoute.name,
         args: UserProfileRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserProfileRoute';

  static const PageInfo<UserProfileRouteArgs> page =
      PageInfo<UserProfileRouteArgs>(name);
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserProfileRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [UserStatusScreen]
class UserStatusRoute extends PageRouteInfo<void> {
  const UserStatusRoute({List<PageRouteInfo>? children})
    : super(UserStatusRoute.name, initialChildren: children);

  static const String name = 'UserStatusRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserWishListScreen]
class UserWishListRoute extends PageRouteInfo<UserWishListRouteArgs> {
  UserWishListRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         UserWishListRoute.name,
         args: UserWishListRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserWishListRoute';

  static const PageInfo<UserWishListRouteArgs> page =
      PageInfo<UserWishListRouteArgs>(name);
}

class UserWishListRouteArgs {
  const UserWishListRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserWishListRouteArgs{key: $key, userId: $userId}';
  }
}
