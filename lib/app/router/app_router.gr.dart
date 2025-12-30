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
    PaymentOptionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PaymentOptionScreen(),
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
    UserAddressFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserAddressFormScreen(),
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
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserCultureFormScreen(),
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
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserEducationFormScreen(),
      );
    },
    UserEmploymentFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserEmploymentFormScreen(),
      );
    },
    UserFamilyFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserFamilyFormScreen(),
      );
    },
    UserHomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserHomeScreen(),
      );
    },
    UserIdentityFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserIdentityFormScreen(),
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
    UserPaymentRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserPaymentScreen(),
      );
    },
    UserPhysicalFormRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const UserPhysicalFormScreen(),
      );
    },
    UserProfileRoute.name: (routeData) {
      final args = routeData.argsAs<UserProfileRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: UserProfileScreen(key: args.key, userId: args.userId),
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
/// [PaymentOptionScreen]
class PaymentOptionRoute extends PageRouteInfo<void> {
  const PaymentOptionRoute({List<PageRouteInfo>? children})
    : super(PaymentOptionRoute.name, initialChildren: children);

  static const String name = 'PaymentOptionRoute';

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
/// [UserAddressFormScreen]
class UserAddressFormRoute extends PageRouteInfo<void> {
  const UserAddressFormRoute({List<PageRouteInfo>? children})
    : super(UserAddressFormRoute.name, initialChildren: children);

  static const String name = 'UserAddressFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
class UserCultureFormRoute extends PageRouteInfo<void> {
  const UserCultureFormRoute({List<PageRouteInfo>? children})
    : super(UserCultureFormRoute.name, initialChildren: children);

  static const String name = 'UserCultureFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
class UserEducationFormRoute extends PageRouteInfo<void> {
  const UserEducationFormRoute({List<PageRouteInfo>? children})
    : super(UserEducationFormRoute.name, initialChildren: children);

  static const String name = 'UserEducationFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserEmploymentFormScreen]
class UserEmploymentFormRoute extends PageRouteInfo<void> {
  const UserEmploymentFormRoute({List<PageRouteInfo>? children})
    : super(UserEmploymentFormRoute.name, initialChildren: children);

  static const String name = 'UserEmploymentFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserFamilyFormScreen]
class UserFamilyFormRoute extends PageRouteInfo<void> {
  const UserFamilyFormRoute({List<PageRouteInfo>? children})
    : super(UserFamilyFormRoute.name, initialChildren: children);

  static const String name = 'UserFamilyFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
class UserIdentityFormRoute extends PageRouteInfo<void> {
  const UserIdentityFormRoute({List<PageRouteInfo>? children})
    : super(UserIdentityFormRoute.name, initialChildren: children);

  static const String name = 'UserIdentityFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [UserLifestyleFormScreen]
class UserLifestyleFormRoute extends PageRouteInfo<void> {
  const UserLifestyleFormRoute({List<PageRouteInfo>? children})
    : super(UserLifestyleFormRoute.name, initialChildren: children);

  static const String name = 'UserLifestyleFormRoute';

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
/// [UserPaymentScreen]
class UserPaymentRoute extends PageRouteInfo<void> {
  const UserPaymentRoute({List<PageRouteInfo>? children})
    : super(UserPaymentRoute.name, initialChildren: children);

  static const String name = 'UserPaymentRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [UserPhysicalFormScreen]
class UserPhysicalFormRoute extends PageRouteInfo<void> {
  const UserPhysicalFormRoute({List<PageRouteInfo>? children})
    : super(UserPhysicalFormRoute.name, initialChildren: children);

  static const String name = 'UserPhysicalFormRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
