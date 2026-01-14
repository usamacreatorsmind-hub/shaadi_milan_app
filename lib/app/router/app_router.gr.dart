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
    AgentActivitiesRoute.name: (routeData) {
      final args = routeData.argsAs<AgentActivitiesRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentActivitiesScreen(
          agentId: args.agentId,
          key: args.key,
        ),
      );
    },
    AgentContactRoute.name: (routeData) {
      final args = routeData.argsAs<AgentContactRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentContactScreen(
          key: args.key,
          agentId: args.agentId,
        ),
      );
    },
    AgentDashboardRoute.name: (routeData) {
      final args = routeData.argsAs<AgentDashboardRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentDashboardScreen(
          agentId: args.agentId,
          key: args.key,
        ),
      );
    },
    AgentEntityRoute.name: (routeData) {
      final args = routeData.argsAs<AgentEntityRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentEntityScreen(
          key: args.key,
          uid: args.uid,
        ),
      );
    },
    AgentHomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AgentHomeScreen(),
      );
    },
    AgentLoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AgentLoginScreen(),
      );
    },
    AgentMainShellRoute.name: (routeData) {
      final args = routeData.argsAs<AgentMainShellRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentMainShellScreen(
          agentId: args.agentId,
          key: args.key,
        ),
      );
    },
    AgentRevenueRoute.name: (routeData) {
      final args = routeData.argsAs<AgentRevenueRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentRevenueScreen(
          key: args.key,
          agentId: args.agentId,
        ),
      );
    },
    AgentSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AgentSettingsScreen(),
      );
    },
    AgentUserRoute.name: (routeData) {
      final args = routeData.argsAs<AgentUserRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AgentUserScreen(
          key: args.key,
          agentId: args.agentId,
        ),
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
    MatrimonyFormFlowRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MatrimonyFormFlowScreen(),
      );
    },
    MetrimonyProfileRoute.name: (routeData) {
      final args = routeData.argsAs<MetrimonyProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MetrimonyProfileScreen(
          key: args.key,
          userId: args.userId,
        ),
      );
    },
    MyProfileDetailRoute.name: (routeData) {
      final args = routeData.argsAs<MyProfileDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MyProfileDetailScreen(
          key: args.key,
          user: args.user,
        ),
      );
    },
    MyProfileRoute.name: (routeData) {
      final args = routeData.argsAs<MyProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MyProfileScreen(
          key: args.key,
          uid: args.uid,
        ),
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
    ResetPasswordRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ResetPasswordScreen(),
      );
    },
    ReviewDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<ReviewDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ReviewDetailsScreen(
          key: args.key,
          review: args.review,
        ),
      );
    },
    ReviewFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ReviewFormScreen(),
      );
    },
    ReviewRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ReviewScreen(),
      );
    },
    RoleSelectionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const RoleSelectionScreen(),
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
    SupportTicketDetailRoute.name: (routeData) {
      final args = routeData.argsAs<SupportTicketDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SupportTicketDetailScreen(
          key: args.key,
          ticketId: args.ticketId,
        ),
      );
    },
    SupportTicketFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SupportTicketFormScreen(),
      );
    },
    SupportTicketsRoute.name: (routeData) {
      final args = routeData.argsAs<SupportTicketsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SupportTicketsScreen(
          key: args.key,
          userId: args.userId,
        ),
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
          registerSubmit: args.registerSubmit,
        ),
      );
    },
    UserBiodataCheckRoute.name: (routeData) {
      final args = routeData.argsAs<UserBiodataCheckRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserBiodataCheckScreen(
          key: args.key,
          isAgreed: args.isAgreed,
        ),
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
          registerSubmit: args.registerSubmit,
        ),
      );
    },
    UserDetailRoute.name: (routeData) {
      final args = routeData.argsAs<UserDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserDetailScreen(
          key: args.key,
          uid: args.uid,
        ),
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
          registerSubmit: args.registerSubmit,
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
          registerSubmit: args.registerSubmit,
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
          registerSubmit: args.registerSubmit,
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
          registerSubmit: args.registerSubmit,
        ),
      );
    },
    UserImageFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserImageFormScreen(),
      );
    },
    UserLoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserLoginScreen(),
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
        child: UserPaymentSuccessScreen(
          key: args.key,
          user: args.user,
        ),
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
          registerSubmit: args.registerSubmit,
        ),
      );
    },
    UserProfileRoute.name: (routeData) {
      final args = routeData.argsAs<UserProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserProfileScreen(
          key: args.key,
          userId: args.userId,
        ),
      );
    },
    // UserProfileRouteOptimized.name: (routeData) {
    //   final args = routeData.argsAs<UserProfileRouteOptimizedArgs>();
    //   return AutoRoutePage<dynamic>(
    //     routeData: routeData,
    //     child: UserProfileScreenOptimized(
    //       key: args.key,
    //       userId: args.userId,
    //     ),
    //   );
    // },
    UserRegisterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserRegisterScreen(),
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
        child: UserWishListScreen(
          key: args.key,
          userId: args.userId,
        ),
      );
    },
    ViewPaymentDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ViewPaymentDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ViewPaymentDetailScreen(
          key: args.key,
          userId: args.userId,
          agentId: args.agentId,
        ),
      );
    },
    ViewUserRoute.name: (routeData) {
      final args = routeData.argsAs<ViewUserRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ViewUserScreen(
          key: args.key,
          agentId: args.agentId,
          userId: args.userId,
        ),
      );
    },
  };
}

/// generated route for
/// [AboutUsScreen]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
      : super(
          AboutUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AboutUsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AgentActivitiesScreen]
class AgentActivitiesRoute extends PageRouteInfo<AgentActivitiesRouteArgs> {
  AgentActivitiesRoute({
    required String agentId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AgentActivitiesRoute.name,
          args: AgentActivitiesRouteArgs(
            agentId: agentId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentActivitiesRoute';

  static const PageInfo<AgentActivitiesRouteArgs> page =
      PageInfo<AgentActivitiesRouteArgs>(name);
}

class AgentActivitiesRouteArgs {
  const AgentActivitiesRouteArgs({
    required this.agentId,
    this.key,
  });

  final String agentId;

  final Key? key;

  @override
  String toString() {
    return 'AgentActivitiesRouteArgs{agentId: $agentId, key: $key}';
  }
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
          args: AgentContactRouteArgs(
            key: key,
            agentId: agentId,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentContactRoute';

  static const PageInfo<AgentContactRouteArgs> page =
      PageInfo<AgentContactRouteArgs>(name);
}

class AgentContactRouteArgs {
  const AgentContactRouteArgs({
    this.key,
    required this.agentId,
  });

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
    required String agentId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AgentDashboardRoute.name,
          args: AgentDashboardRouteArgs(
            agentId: agentId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentDashboardRoute';

  static const PageInfo<AgentDashboardRouteArgs> page =
      PageInfo<AgentDashboardRouteArgs>(name);
}

class AgentDashboardRouteArgs {
  const AgentDashboardRouteArgs({
    required this.agentId,
    this.key,
  });

  final String agentId;

  final Key? key;

  @override
  String toString() {
    return 'AgentDashboardRouteArgs{agentId: $agentId, key: $key}';
  }
}

/// generated route for
/// [AgentEntityScreen]
class AgentEntityRoute extends PageRouteInfo<AgentEntityRouteArgs> {
  AgentEntityRoute({
    Key? key,
    required String uid,
    List<PageRouteInfo>? children,
  }) : super(
          AgentEntityRoute.name,
          args: AgentEntityRouteArgs(
            key: key,
            uid: uid,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentEntityRoute';

  static const PageInfo<AgentEntityRouteArgs> page =
      PageInfo<AgentEntityRouteArgs>(name);
}

class AgentEntityRouteArgs {
  const AgentEntityRouteArgs({
    this.key,
    required this.uid,
  });

  final Key? key;

  final String uid;

  @override
  String toString() {
    return 'AgentEntityRouteArgs{key: $key, uid: $uid}';
  }
}

/// generated route for
/// [AgentHomeScreen]
class AgentHomeRoute extends PageRouteInfo<void> {
  const AgentHomeRoute({List<PageRouteInfo>? children})
      : super(
          AgentHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'AgentHomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AgentLoginScreen]
class AgentLoginRoute extends PageRouteInfo<void> {
  const AgentLoginRoute({List<PageRouteInfo>? children})
      : super(
          AgentLoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'AgentLoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AgentMainShellScreen]
class AgentMainShellRoute extends PageRouteInfo<AgentMainShellRouteArgs> {
  AgentMainShellRoute({
    required String agentId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AgentMainShellRoute.name,
          args: AgentMainShellRouteArgs(
            agentId: agentId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentMainShellRoute';

  static const PageInfo<AgentMainShellRouteArgs> page =
      PageInfo<AgentMainShellRouteArgs>(name);
}

class AgentMainShellRouteArgs {
  const AgentMainShellRouteArgs({
    required this.agentId,
    this.key,
  });

  final String agentId;

  final Key? key;

  @override
  String toString() {
    return 'AgentMainShellRouteArgs{agentId: $agentId, key: $key}';
  }
}

/// generated route for
/// [AgentRevenueScreen]
class AgentRevenueRoute extends PageRouteInfo<AgentRevenueRouteArgs> {
  AgentRevenueRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
          AgentRevenueRoute.name,
          args: AgentRevenueRouteArgs(
            key: key,
            agentId: agentId,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentRevenueRoute';

  static const PageInfo<AgentRevenueRouteArgs> page =
      PageInfo<AgentRevenueRouteArgs>(name);
}

class AgentRevenueRouteArgs {
  const AgentRevenueRouteArgs({
    this.key,
    required this.agentId,
  });

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'AgentRevenueRouteArgs{key: $key, agentId: $agentId}';
  }
}

/// generated route for
/// [AgentSettingsScreen]
class AgentSettingsRoute extends PageRouteInfo<void> {
  const AgentSettingsRoute({List<PageRouteInfo>? children})
      : super(
          AgentSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AgentSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AgentUserScreen]
class AgentUserRoute extends PageRouteInfo<AgentUserRouteArgs> {
  AgentUserRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
          AgentUserRoute.name,
          args: AgentUserRouteArgs(
            key: key,
            agentId: agentId,
          ),
          initialChildren: children,
        );

  static const String name = 'AgentUserRoute';

  static const PageInfo<AgentUserRouteArgs> page =
      PageInfo<AgentUserRouteArgs>(name);
}

class AgentUserRouteArgs {
  const AgentUserRouteArgs({
    this.key,
    required this.agentId,
  });

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'AgentUserRouteArgs{key: $key, agentId: $agentId}';
  }
}

/// generated route for
/// [AuthWrapperScreen]
class AuthWrapperRoute extends PageRouteInfo<void> {
  const AuthWrapperRoute({List<PageRouteInfo>? children})
      : super(
          AuthWrapperRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthWrapperRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
      : super(
          ChangePasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChangePasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ContactUsScreen]
class ContactUsRoute extends PageRouteInfo<void> {
  const ContactUsRoute({List<PageRouteInfo>? children})
      : super(
          ContactUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactUsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MatrimonyFormFlowScreen]
class MatrimonyFormFlowRoute extends PageRouteInfo<void> {
  const MatrimonyFormFlowRoute({List<PageRouteInfo>? children})
      : super(
          MatrimonyFormFlowRoute.name,
          initialChildren: children,
        );

  static const String name = 'MatrimonyFormFlowRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MetrimonyProfileScreen]
class MetrimonyProfileRoute extends PageRouteInfo<MetrimonyProfileRouteArgs> {
  MetrimonyProfileRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          MetrimonyProfileRoute.name,
          args: MetrimonyProfileRouteArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'MetrimonyProfileRoute';

  static const PageInfo<MetrimonyProfileRouteArgs> page =
      PageInfo<MetrimonyProfileRouteArgs>(name);
}

class MetrimonyProfileRouteArgs {
  const MetrimonyProfileRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'MetrimonyProfileRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [MyProfileDetailScreen]
class MyProfileDetailRoute extends PageRouteInfo<MyProfileDetailRouteArgs> {
  MyProfileDetailRoute({
    Key? key,
    required UserEntity user,
    List<PageRouteInfo>? children,
  }) : super(
          MyProfileDetailRoute.name,
          args: MyProfileDetailRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'MyProfileDetailRoute';

  static const PageInfo<MyProfileDetailRouteArgs> page =
      PageInfo<MyProfileDetailRouteArgs>(name);
}

class MyProfileDetailRouteArgs {
  const MyProfileDetailRouteArgs({
    this.key,
    required this.user,
  });

  final Key? key;

  final UserEntity user;

  @override
  String toString() {
    return 'MyProfileDetailRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [MyProfileScreen]
class MyProfileRoute extends PageRouteInfo<MyProfileRouteArgs> {
  MyProfileRoute({
    Key? key,
    required String uid,
    List<PageRouteInfo>? children,
  }) : super(
          MyProfileRoute.name,
          args: MyProfileRouteArgs(
            key: key,
            uid: uid,
          ),
          initialChildren: children,
        );

  static const String name = 'MyProfileRoute';

  static const PageInfo<MyProfileRouteArgs> page =
      PageInfo<MyProfileRouteArgs>(name);
}

class MyProfileRouteArgs {
  const MyProfileRouteArgs({
    this.key,
    required this.uid,
  });

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
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
      : super(
          PrivacyPolicyRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrivacyPolicyRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ResetPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ResetPasswordRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReviewDetailsScreen]
class ReviewDetailsRoute extends PageRouteInfo<ReviewDetailsRouteArgs> {
  ReviewDetailsRoute({
    Key? key,
    required Review review,
    List<PageRouteInfo>? children,
  }) : super(
          ReviewDetailsRoute.name,
          args: ReviewDetailsRouteArgs(
            key: key,
            review: review,
          ),
          initialChildren: children,
        );

  static const String name = 'ReviewDetailsRoute';

  static const PageInfo<ReviewDetailsRouteArgs> page =
      PageInfo<ReviewDetailsRouteArgs>(name);
}

class ReviewDetailsRouteArgs {
  const ReviewDetailsRouteArgs({
    this.key,
    required this.review,
  });

  final Key? key;

  final Review review;

  @override
  String toString() {
    return 'ReviewDetailsRouteArgs{key: $key, review: $review}';
  }
}

/// generated route for
/// [ReviewFormScreen]
class ReviewFormRoute extends PageRouteInfo<void> {
  const ReviewFormRoute({List<PageRouteInfo>? children})
      : super(
          ReviewFormRoute.name,
          initialChildren: children,
        );

  static const String name = 'ReviewFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReviewScreen]
class ReviewRoute extends PageRouteInfo<void> {
  const ReviewRoute({List<PageRouteInfo>? children})
      : super(
          ReviewRoute.name,
          initialChildren: children,
        );

  static const String name = 'ReviewRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RoleSelectionScreen]
class RoleSelectionRoute extends PageRouteInfo<void> {
  const RoleSelectionRoute({List<PageRouteInfo>? children})
      : super(
          RoleSelectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'RoleSelectionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SupportTicketDetailScreen]
class SupportTicketDetailRoute
    extends PageRouteInfo<SupportTicketDetailRouteArgs> {
  SupportTicketDetailRoute({
    Key? key,
    required String ticketId,
    List<PageRouteInfo>? children,
  }) : super(
          SupportTicketDetailRoute.name,
          args: SupportTicketDetailRouteArgs(
            key: key,
            ticketId: ticketId,
          ),
          initialChildren: children,
        );

  static const String name = 'SupportTicketDetailRoute';

  static const PageInfo<SupportTicketDetailRouteArgs> page =
      PageInfo<SupportTicketDetailRouteArgs>(name);
}

class SupportTicketDetailRouteArgs {
  const SupportTicketDetailRouteArgs({
    this.key,
    required this.ticketId,
  });

  final Key? key;

  final String ticketId;

  @override
  String toString() {
    return 'SupportTicketDetailRouteArgs{key: $key, ticketId: $ticketId}';
  }
}

/// generated route for
/// [SupportTicketFormScreen]
class SupportTicketFormRoute extends PageRouteInfo<void> {
  const SupportTicketFormRoute({List<PageRouteInfo>? children})
      : super(
          SupportTicketFormRoute.name,
          initialChildren: children,
        );

  static const String name = 'SupportTicketFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SupportTicketsScreen]
class SupportTicketsRoute extends PageRouteInfo<SupportTicketsRouteArgs> {
  SupportTicketsRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          SupportTicketsRoute.name,
          args: SupportTicketsRouteArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'SupportTicketsRoute';

  static const PageInfo<SupportTicketsRouteArgs> page =
      PageInfo<SupportTicketsRouteArgs>(name);
}

class SupportTicketsRouteArgs {
  const SupportTicketsRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'SupportTicketsRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [TermsAndConditionsScreen]
class TermsAndConditionsRoute extends PageRouteInfo<void> {
  const TermsAndConditionsRoute({List<PageRouteInfo>? children})
      : super(
          TermsAndConditionsRoute.name,
          initialChildren: children,
        );

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
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserAddressFormRoute.name,
          args: UserAddressFormRouteArgs(
            key: key,
            mode: mode,
            existingAddressProfile: existingAddressProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final AddressProfile? existingAddressProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserAddressFormRouteArgs{key: $key, mode: $mode, existingAddressProfile: $existingAddressProfile, registerSubmit: $registerSubmit}';
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
          args: UserBiodataCheckRouteArgs(
            key: key,
            isAgreed: isAgreed,
          ),
          initialChildren: children,
        );

  static const String name = 'UserBiodataCheckRoute';

  static const PageInfo<UserBiodataCheckRouteArgs> page =
      PageInfo<UserBiodataCheckRouteArgs>(name);
}

class UserBiodataCheckRouteArgs {
  const UserBiodataCheckRouteArgs({
    this.key,
    required this.isAgreed,
  });

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
      : super(
          UserChatRoute.name,
          initialChildren: children,
        );

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
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserCultureFormRoute.name,
          args: UserCultureFormRouteArgs(
            key: key,
            mode: mode,
            existingCulturalProfile: existingCulturalProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final CulturalProfile? existingCulturalProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserCultureFormRouteArgs{key: $key, mode: $mode, existingCulturalProfile: $existingCulturalProfile, registerSubmit: $registerSubmit}';
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
          args: UserDetailRouteArgs(
            key: key,
            uid: uid,
          ),
          initialChildren: children,
        );

  static const String name = 'UserDetailRoute';

  static const PageInfo<UserDetailRouteArgs> page =
      PageInfo<UserDetailRouteArgs>(name);
}

class UserDetailRouteArgs {
  const UserDetailRouteArgs({
    this.key,
    required this.uid,
  });

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
    EducationProfile? existingEducationProfile,
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserEducationFormRoute.name,
          args: UserEducationFormRouteArgs(
            key: key,
            mode: mode,
            existingEducationProfile: existingEducationProfile,
            registerSubmit: registerSubmit,
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
    this.existingEducationProfile,
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final EducationProfile? existingEducationProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserEducationFormRouteArgs{key: $key, mode: $mode, existingEducationProfile: $existingEducationProfile, registerSubmit: $registerSubmit}';
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
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserEmploymentFormRoute.name,
          args: UserEmploymentFormRouteArgs(
            key: key,
            mode: mode,
            existingEmploymentProfile: existingEmploymentProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final EmploymentProfile? existingEmploymentProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserEmploymentFormRouteArgs{key: $key, mode: $mode, existingEmploymentProfile: $existingEmploymentProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserFamilyFormScreen]
class UserFamilyFormRoute extends PageRouteInfo<UserFamilyFormRouteArgs> {
  UserFamilyFormRoute({
    Key? key,
    required FormMode mode,
    required FamilyProfile? existingFamilyProfile,
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserFamilyFormRoute.name,
          args: UserFamilyFormRouteArgs(
            key: key,
            mode: mode,
            existingFamilyProfile: existingFamilyProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final FamilyProfile? existingFamilyProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserFamilyFormRouteArgs{key: $key, mode: $mode, existingFamilyProfile: $existingFamilyProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserHomeScreen]
class UserHomeRoute extends PageRouteInfo<void> {
  const UserHomeRoute({List<PageRouteInfo>? children})
      : super(
          UserHomeRoute.name,
          initialChildren: children,
        );

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
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserIdentityFormRoute.name,
          args: UserIdentityFormRouteArgs(
            key: key,
            mode: mode,
            existingIdentityProfile: existingIdentityProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final IdentityProfile? existingIdentityProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserIdentityFormRouteArgs{key: $key, mode: $mode, existingIdentityProfile: $existingIdentityProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserImageFormScreen]
class UserImageFormRoute extends PageRouteInfo<void> {
  const UserImageFormRoute({List<PageRouteInfo>? children})
      : super(
          UserImageFormRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserImageFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserLoginScreen]
class UserLoginRoute extends PageRouteInfo<void> {
  const UserLoginRoute({List<PageRouteInfo>? children})
      : super(
          UserLoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserLoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserMainShellScreen]
class UserMainShellRoute extends PageRouteInfo<void> {
  const UserMainShellRoute({List<PageRouteInfo>? children})
      : super(
          UserMainShellRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserMainShellRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserNotificationScreen]
class UserNotificationRoute extends PageRouteInfo<void> {
  const UserNotificationRoute({List<PageRouteInfo>? children})
      : super(
          UserNotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserNotificationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserPaymentOrderHistoryScreen]
class UserPaymentOrderHistoryRoute extends PageRouteInfo<void> {
  const UserPaymentOrderHistoryRoute({List<PageRouteInfo>? children})
      : super(
          UserPaymentOrderHistoryRoute.name,
          initialChildren: children,
        );

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
    required UserEntity user,
    List<PageRouteInfo>? children,
  }) : super(
          UserPaymentSuccessRoute.name,
          args: UserPaymentSuccessRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'UserPaymentSuccessRoute';

  static const PageInfo<UserPaymentSuccessRouteArgs> page =
      PageInfo<UserPaymentSuccessRouteArgs>(name);
}

class UserPaymentSuccessRouteArgs {
  const UserPaymentSuccessRouteArgs({
    this.key,
    required this.user,
  });

  final Key? key;

  final UserEntity user;

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
    void Function(void Function())? registerSubmit,
    List<PageRouteInfo>? children,
  }) : super(
          UserPhysicalFormRoute.name,
          args: UserPhysicalFormRouteArgs(
            key: key,
            mode: mode,
            existingPhysicalProfile: existingPhysicalProfile,
            registerSubmit: registerSubmit,
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
    this.registerSubmit,
  });

  final Key? key;

  final FormMode mode;

  final PhysicalProfile? existingPhysicalProfile;

  final void Function(void Function())? registerSubmit;

  @override
  String toString() {
    return 'UserPhysicalFormRouteArgs{key: $key, mode: $mode, existingPhysicalProfile: $existingPhysicalProfile, registerSubmit: $registerSubmit}';
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
          args: UserProfileRouteArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'UserProfileRoute';

  static const PageInfo<UserProfileRouteArgs> page =
      PageInfo<UserProfileRouteArgs>(name);
}

class UserProfileRouteArgs {
  const UserProfileRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserProfileRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [UserProfileScreenOptimized]
class UserProfileRouteOptimized
    extends PageRouteInfo<UserProfileRouteOptimizedArgs> {
  UserProfileRouteOptimized({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          UserProfileRouteOptimized.name,
          args: UserProfileRouteOptimizedArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'UserProfileRouteOptimized';

  static const PageInfo<UserProfileRouteOptimizedArgs> page =
      PageInfo<UserProfileRouteOptimizedArgs>(name);
}

class UserProfileRouteOptimizedArgs {
  const UserProfileRouteOptimizedArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserProfileRouteOptimizedArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [UserRegisterScreen]
class UserRegisterRoute extends PageRouteInfo<void> {
  const UserRegisterRoute({List<PageRouteInfo>? children})
      : super(
          UserRegisterRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserRegisterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserStatusScreen]
class UserStatusRoute extends PageRouteInfo<void> {
  const UserStatusRoute({List<PageRouteInfo>? children})
      : super(
          UserStatusRoute.name,
          initialChildren: children,
        );

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
          args: UserWishListRouteArgs(
            key: key,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'UserWishListRoute';

  static const PageInfo<UserWishListRouteArgs> page =
      PageInfo<UserWishListRouteArgs>(name);
}

class UserWishListRouteArgs {
  const UserWishListRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserWishListRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [ViewPaymentDetailScreen]
class ViewPaymentDetailRoute extends PageRouteInfo<ViewPaymentDetailRouteArgs> {
  ViewPaymentDetailRoute({
    Key? key,
    required String userId,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
          ViewPaymentDetailRoute.name,
          args: ViewPaymentDetailRouteArgs(
            key: key,
            userId: userId,
            agentId: agentId,
          ),
          initialChildren: children,
        );

  static const String name = 'ViewPaymentDetailRoute';

  static const PageInfo<ViewPaymentDetailRouteArgs> page =
      PageInfo<ViewPaymentDetailRouteArgs>(name);
}

class ViewPaymentDetailRouteArgs {
  const ViewPaymentDetailRouteArgs({
    this.key,
    required this.userId,
    required this.agentId,
  });

  final Key? key;

  final String userId;

  final String agentId;

  @override
  String toString() {
    return 'ViewPaymentDetailRouteArgs{key: $key, userId: $userId, agentId: $agentId}';
  }
}

/// generated route for
/// [ViewUserScreen]
class ViewUserRoute extends PageRouteInfo<ViewUserRouteArgs> {
  ViewUserRoute({
    Key? key,
    required String agentId,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          ViewUserRoute.name,
          args: ViewUserRouteArgs(
            key: key,
            agentId: agentId,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'ViewUserRoute';

  static const PageInfo<ViewUserRouteArgs> page =
      PageInfo<ViewUserRouteArgs>(name);
}

class ViewUserRouteArgs {
  const ViewUserRouteArgs({
    this.key,
    required this.agentId,
    required this.userId,
  });

  final Key? key;

  final String agentId;

  final String userId;

  @override
  String toString() {
    return 'ViewUserRouteArgs{key: $key, agentId: $agentId, userId: $userId}';
  }
}
