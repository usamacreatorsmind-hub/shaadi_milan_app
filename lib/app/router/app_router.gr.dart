// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutUsScreen]
class AboutUsRoute extends PageRouteInfo<void> {
  const AboutUsRoute({List<PageRouteInfo>? children})
    : super(AboutUsRoute.name, initialChildren: children);

  static const String name = 'AboutUsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutUsScreen();
    },
  );
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
         args: AgentActivitiesRouteArgs(agentId: agentId, key: key),
         initialChildren: children,
       );

  static const String name = 'AgentActivitiesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentActivitiesRouteArgs>();
      return AgentActivitiesScreen(agentId: args.agentId, key: args.key);
    },
  );
}

class AgentActivitiesRouteArgs {
  const AgentActivitiesRouteArgs({required this.agentId, this.key});

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
         args: AgentContactRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentContactRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentContactRouteArgs>();
      return AgentContactScreen(key: args.key, agentId: args.agentId);
    },
  );
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
    required String agentId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         AgentDashboardRoute.name,
         args: AgentDashboardRouteArgs(agentId: agentId, key: key),
         initialChildren: children,
       );

  static const String name = 'AgentDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentDashboardRouteArgs>();
      return AgentDashboardScreen(agentId: args.agentId, key: args.key);
    },
  );
}

class AgentDashboardRouteArgs {
  const AgentDashboardRouteArgs({required this.agentId, this.key});

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
         args: AgentEntityRouteArgs(key: key, uid: uid),
         initialChildren: children,
       );

  static const String name = 'AgentEntityRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentEntityRouteArgs>();
      return AgentEntityScreen(key: args.key, uid: args.uid);
    },
  );
}

class AgentEntityRouteArgs {
  const AgentEntityRouteArgs({this.key, required this.uid});

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
    : super(AgentHomeRoute.name, initialChildren: children);

  static const String name = 'AgentHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AgentHomeScreen();
    },
  );
}

/// generated route for
/// [AgentLoginScreen]
class AgentLoginRoute extends PageRouteInfo<void> {
  const AgentLoginRoute({List<PageRouteInfo>? children})
    : super(AgentLoginRoute.name, initialChildren: children);

  static const String name = 'AgentLoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AgentLoginScreen();
    },
  );
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
         args: AgentMainShellRouteArgs(agentId: agentId, key: key),
         initialChildren: children,
       );

  static const String name = 'AgentMainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentMainShellRouteArgs>();
      return AgentMainShellScreen(agentId: args.agentId, key: args.key);
    },
  );
}

class AgentMainShellRouteArgs {
  const AgentMainShellRouteArgs({required this.agentId, this.key});

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
         args: AgentRevenueRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentRevenueRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentRevenueRouteArgs>();
      return AgentRevenueScreen(key: args.key, agentId: args.agentId);
    },
  );
}

class AgentRevenueRouteArgs {
  const AgentRevenueRouteArgs({this.key, required this.agentId});

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
    : super(AgentSettingsRoute.name, initialChildren: children);

  static const String name = 'AgentSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AgentSettingsScreen();
    },
  );
}

/// generated route for
/// [AgentSupportScreen]
class AgentSupportRoute extends PageRouteInfo<AgentSupportRouteArgs> {
  AgentSupportRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
         AgentSupportRoute.name,
         args: AgentSupportRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentSupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentSupportRouteArgs>();
      return AgentSupportScreen(key: args.key, agentId: args.agentId);
    },
  );
}

class AgentSupportRouteArgs {
  const AgentSupportRouteArgs({this.key, required this.agentId});

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'AgentSupportRouteArgs{key: $key, agentId: $agentId}';
  }
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
         args: AgentUserRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'AgentUserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AgentUserRouteArgs>();
      return AgentUserScreen(key: args.key, agentId: args.agentId);
    },
  );
}

class AgentUserRouteArgs {
  const AgentUserRouteArgs({this.key, required this.agentId});

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
    : super(AuthWrapperRoute.name, initialChildren: children);

  static const String name = 'AuthWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthWrapperScreen();
    },
  );
}

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [ContactUsScreen]
class ContactUsRoute extends PageRouteInfo<void> {
  const ContactUsRoute({List<PageRouteInfo>? children})
    : super(ContactUsRoute.name, initialChildren: children);

  static const String name = 'ContactUsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ContactUsScreen();
    },
  );
}

/// generated route for
/// [MatrimonyFormFlowScreen]
class MatrimonyFormFlowRoute extends PageRouteInfo<void> {
  const MatrimonyFormFlowRoute({List<PageRouteInfo>? children})
    : super(MatrimonyFormFlowRoute.name, initialChildren: children);

  static const String name = 'MatrimonyFormFlowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MatrimonyFormFlowScreen();
    },
  );
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
         args: MetrimonyProfileRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'MetrimonyProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MetrimonyProfileRouteArgs>();
      return MetrimonyProfileScreen(key: args.key, userId: args.userId);
    },
  );
}

class MetrimonyProfileRouteArgs {
  const MetrimonyProfileRouteArgs({this.key, required this.userId});

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
         args: MyProfileDetailRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'MyProfileDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MyProfileDetailRouteArgs>();
      return MyProfileDetailScreen(key: args.key, user: args.user);
    },
  );
}

class MyProfileDetailRouteArgs {
  const MyProfileDetailRouteArgs({this.key, required this.user});

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
  MyProfileRoute({Key? key, required String uid, List<PageRouteInfo>? children})
    : super(
        MyProfileRoute.name,
        args: MyProfileRouteArgs(key: key, uid: uid),
        initialChildren: children,
      );

  static const String name = 'MyProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MyProfileRouteArgs>();
      return MyProfileScreen(key: args.key, uid: args.uid);
    },
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
/// [MyReviewScreen]
class MyReviewRoute extends PageRouteInfo<void> {
  const MyReviewRoute({List<PageRouteInfo>? children})
    : super(MyReviewRoute.name, initialChildren: children);

  static const String name = 'MyReviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyReviewScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<void> {
  const OnboardingRoute({List<PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardingScreen();
    },
  );
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
    : super(ResetPasswordRoute.name, initialChildren: children);

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordScreen();
    },
  );
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
         args: ReviewDetailsRouteArgs(key: key, review: review),
         initialChildren: children,
       );

  static const String name = 'ReviewDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReviewDetailsRouteArgs>();
      return ReviewDetailsScreen(key: args.key, review: args.review);
    },
  );
}

class ReviewDetailsRouteArgs {
  const ReviewDetailsRouteArgs({this.key, required this.review});

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
    : super(ReviewFormRoute.name, initialChildren: children);

  static const String name = 'ReviewFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReviewFormScreen();
    },
  );
}

/// generated route for
/// [ReviewScreen]
class ReviewRoute extends PageRouteInfo<void> {
  const ReviewRoute({List<PageRouteInfo>? children})
    : super(ReviewRoute.name, initialChildren: children);

  static const String name = 'ReviewRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReviewScreen();
    },
  );
}

/// generated route for
/// [RoleSelectionScreen]
class RoleSelectionRoute extends PageRouteInfo<void> {
  const RoleSelectionRoute({List<PageRouteInfo>? children})
    : super(RoleSelectionRoute.name, initialChildren: children);

  static const String name = 'RoleSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RoleSelectionScreen();
    },
  );
}

/// generated route for
/// [SearchScreen]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
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
         args: SupportTicketDetailRouteArgs(key: key, ticketId: ticketId),
         initialChildren: children,
       );

  static const String name = 'SupportTicketDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportTicketDetailRouteArgs>();
      return SupportTicketDetailScreen(key: args.key, ticketId: args.ticketId);
    },
  );
}

class SupportTicketDetailRouteArgs {
  const SupportTicketDetailRouteArgs({this.key, required this.ticketId});

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
    : super(SupportTicketFormRoute.name, initialChildren: children);

  static const String name = 'SupportTicketFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SupportTicketFormScreen();
    },
  );
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
         args: SupportTicketsRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'SupportTicketsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportTicketsRouteArgs>();
      return SupportTicketsScreen(key: args.key, userId: args.userId);
    },
  );
}

class SupportTicketsRouteArgs {
  const SupportTicketsRouteArgs({this.key, required this.userId});

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
    : super(TermsAndConditionsRoute.name, initialChildren: children);

  static const String name = 'TermsAndConditionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsAndConditionsScreen();
    },
  );
}

/// generated route for
/// [UserAddressFormScreen]
class UserAddressFormRoute extends PageRouteInfo<UserAddressFormRouteArgs> {
  UserAddressFormRoute({
    Key? key,
    required FormMode mode,
    required AddressProfile? existingAddressProfile,
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserAddressFormRouteArgs>();
      return UserAddressFormScreen(
        key: args.key,
        mode: args.mode,
        existingAddressProfile: args.existingAddressProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

  @override
  String toString() {
    return 'UserAddressFormRouteArgs{key: $key, mode: $mode, existingAddressProfile: $existingAddressProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserAfterMarriagePaymentScreen]
class UserAfterMarriagePaymentRoute
    extends PageRouteInfo<UserAfterMarriagePaymentRouteArgs> {
  UserAfterMarriagePaymentRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         UserAfterMarriagePaymentRoute.name,
         args: UserAfterMarriagePaymentRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserAfterMarriagePaymentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserAfterMarriagePaymentRouteArgs>();
      return UserAfterMarriagePaymentScreen(key: args.key, userId: args.userId);
    },
  );
}

class UserAfterMarriagePaymentRouteArgs {
  const UserAfterMarriagePaymentRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserAfterMarriagePaymentRouteArgs{key: $key, userId: $userId}';
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserBiodataCheckRouteArgs>();
      return UserBiodataCheckScreen(key: args.key, isAgreed: args.isAgreed);
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserChatScreen();
    },
  );
}

/// generated route for
/// [UserCultureFormScreen]
class UserCultureFormRoute extends PageRouteInfo<UserCultureFormRouteArgs> {
  UserCultureFormRoute({
    Key? key,
    required FormMode mode,
    CulturalProfile? existingCulturalProfile,
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserCultureFormRouteArgs>();
      return UserCultureFormScreen(
        key: args.key,
        mode: args.mode,
        existingCulturalProfile: args.existingCulturalProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

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
         args: UserDetailRouteArgs(key: key, uid: uid),
         initialChildren: children,
       );

  static const String name = 'UserDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserDetailRouteArgs>();
      return UserDetailScreen(key: args.key, uid: args.uid);
    },
  );
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
    EducationProfile? existingEducationProfile,
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserEducationFormRouteArgs>();
      return UserEducationFormScreen(
        key: args.key,
        mode: args.mode,
        existingEducationProfile: args.existingEducationProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

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
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserEmploymentFormRouteArgs>();
      return UserEmploymentFormScreen(
        key: args.key,
        mode: args.mode,
        existingEmploymentProfile: args.existingEmploymentProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

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
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserFamilyFormRouteArgs>();
      return UserFamilyFormScreen(
        key: args.key,
        mode: args.mode,
        existingFamilyProfile: args.existingFamilyProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

  @override
  String toString() {
    return 'UserFamilyFormRouteArgs{key: $key, mode: $mode, existingFamilyProfile: $existingFamilyProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserHomeScreen]
class UserHomeRoute extends PageRouteInfo<void> {
  const UserHomeRoute({List<PageRouteInfo>? children})
    : super(UserHomeRoute.name, initialChildren: children);

  static const String name = 'UserHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserHomeScreen();
    },
  );
}

/// generated route for
/// [UserIdentityFormScreen]
class UserIdentityFormRoute extends PageRouteInfo<UserIdentityFormRouteArgs> {
  UserIdentityFormRoute({
    Key? key,
    required FormMode mode,
    IdentityProfile? existingIdentityProfile,
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserIdentityFormRouteArgs>();
      return UserIdentityFormScreen(
        key: args.key,
        mode: args.mode,
        existingIdentityProfile: args.existingIdentityProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

  @override
  String toString() {
    return 'UserIdentityFormRouteArgs{key: $key, mode: $mode, existingIdentityProfile: $existingIdentityProfile, registerSubmit: $registerSubmit}';
  }
}

/// generated route for
/// [UserImageFormScreen]
class UserImageFormRoute extends PageRouteInfo<void> {
  const UserImageFormRoute({List<PageRouteInfo>? children})
    : super(UserImageFormRoute.name, initialChildren: children);

  static const String name = 'UserImageFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserImageFormScreen();
    },
  );
}

/// generated route for
/// [UserLoginScreen]
class UserLoginRoute extends PageRouteInfo<void> {
  const UserLoginRoute({List<PageRouteInfo>? children})
    : super(UserLoginRoute.name, initialChildren: children);

  static const String name = 'UserLoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserLoginScreen();
    },
  );
}

/// generated route for
/// [UserMainShellScreen]
class UserMainShellRoute extends PageRouteInfo<void> {
  const UserMainShellRoute({List<PageRouteInfo>? children})
    : super(UserMainShellRoute.name, initialChildren: children);

  static const String name = 'UserMainShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserMainShellScreen();
    },
  );
}

/// generated route for
/// [UserNotificationScreen]
class UserNotificationRoute extends PageRouteInfo<void> {
  const UserNotificationRoute({List<PageRouteInfo>? children})
    : super(UserNotificationRoute.name, initialChildren: children);

  static const String name = 'UserNotificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserNotificationScreen();
    },
  );
}

/// generated route for
/// [UserPaymentOrderHistoryScreen]
class UserPaymentOrderHistoryRoute extends PageRouteInfo<void> {
  const UserPaymentOrderHistoryRoute({List<PageRouteInfo>? children})
    : super(UserPaymentOrderHistoryRoute.name, initialChildren: children);

  static const String name = 'UserPaymentOrderHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserPaymentOrderHistoryScreen();
    },
  );
}

/// generated route for
/// [UserPaymentScreen]
class UserPaymentRoute extends PageRouteInfo<UserPaymentRouteArgs> {
  UserPaymentRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         UserPaymentRoute.name,
         args: UserPaymentRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserPaymentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserPaymentRouteArgs>();
      return UserPaymentScreen(key: args.key, userId: args.userId);
    },
  );
}

class UserPaymentRouteArgs {
  const UserPaymentRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'UserPaymentRouteArgs{key: $key, userId: $userId}';
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
         args: UserPaymentSuccessRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'UserPaymentSuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserPaymentSuccessRouteArgs>();
      return UserPaymentSuccessScreen(key: args.key, user: args.user);
    },
  );
}

class UserPaymentSuccessRouteArgs {
  const UserPaymentSuccessRouteArgs({this.key, required this.user});

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
    void Function(VoidCallback)? registerSubmit,
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserPhysicalFormRouteArgs>();
      return UserPhysicalFormScreen(
        key: args.key,
        mode: args.mode,
        existingPhysicalProfile: args.existingPhysicalProfile,
        registerSubmit: args.registerSubmit,
      );
    },
  );
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

  final void Function(VoidCallback)? registerSubmit;

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
         args: UserProfileRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'UserProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserProfileRouteArgs>();
      return UserProfileScreen(key: args.key, userId: args.userId);
    },
  );
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
/// [UserRegisterScreen]
class UserRegisterRoute extends PageRouteInfo<void> {
  const UserRegisterRoute({List<PageRouteInfo>? children})
    : super(UserRegisterRoute.name, initialChildren: children);

  static const String name = 'UserRegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserRegisterScreen();
    },
  );
}

/// generated route for
/// [UserStatusScreen]
class UserStatusRoute extends PageRouteInfo<void> {
  const UserStatusRoute({List<PageRouteInfo>? children})
    : super(UserStatusRoute.name, initialChildren: children);

  static const String name = 'UserStatusRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserStatusScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserWishListRouteArgs>();
      return UserWishListScreen(key: args.key, userId: args.userId);
    },
  );
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

/// generated route for
/// [ViewAgentProfileScreen]
class ViewAgentProfileRoute extends PageRouteInfo<ViewAgentProfileRouteArgs> {
  ViewAgentProfileRoute({
    Key? key,
    required String agentId,
    List<PageRouteInfo>? children,
  }) : super(
         ViewAgentProfileRoute.name,
         args: ViewAgentProfileRouteArgs(key: key, agentId: agentId),
         initialChildren: children,
       );

  static const String name = 'ViewAgentProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewAgentProfileRouteArgs>();
      return ViewAgentProfileScreen(key: args.key, agentId: args.agentId);
    },
  );
}

class ViewAgentProfileRouteArgs {
  const ViewAgentProfileRouteArgs({this.key, required this.agentId});

  final Key? key;

  final String agentId;

  @override
  String toString() {
    return 'ViewAgentProfileRouteArgs{key: $key, agentId: $agentId}';
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewPaymentDetailRouteArgs>();
      return ViewPaymentDetailScreen(
        key: args.key,
        userId: args.userId,
        agentId: args.agentId,
      );
    },
  );
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
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         ViewUserRoute.name,
         args: ViewUserRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'ViewUserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewUserRouteArgs>();
      return ViewUserScreen(key: args.key, userId: args.userId);
    },
  );
}

class ViewUserRouteArgs {
  const ViewUserRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'ViewUserRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [ViewWishListUserScreen]
class ViewWishListUserRoute extends PageRouteInfo<ViewWishListUserRouteArgs> {
  ViewWishListUserRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
         ViewWishListUserRoute.name,
         args: ViewWishListUserRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'ViewWishListUserRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ViewWishListUserRouteArgs>();
      return ViewWishListUserScreen(key: args.key, userId: args.userId);
    },
  );
}

class ViewWishListUserRouteArgs {
  const ViewWishListUserRouteArgs({this.key, required this.userId});

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'ViewWishListUserRouteArgs{key: $key, userId: $userId}';
  }
}
