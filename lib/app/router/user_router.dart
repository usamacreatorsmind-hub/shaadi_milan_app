import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'auth_guard.dart';
import 'user_guard.dart';

class UserRouter {
  static List<AutoRoute> routes(Ref ref) => [
    // ================= USER MAIN SHELL (BOTTOM NAV) =================
    AutoRoute(
      page: UserMainShellRoute.page,

      children: [
        AutoRoute(
          page: UserHomeRoute.page,
          initial: true,
          guards: [AuthGuard(ref), UserGuard(ref)],
        ),

        AutoRoute(
          page: UserWishListRoute.page,
          guards: [AuthGuard(ref), UserGuard(ref)],
        ),

        AutoRoute(
          page: UserChatRoute.page,
          guards: [AuthGuard(ref), UserGuard(ref)],
        ),
        AutoRoute(
          page: SupportTicketsRoute.page,
          guards: [AuthGuard(ref), UserGuard(ref)],
        ),

        AutoRoute(
          page: UserProfileRoute.page,
          guards: [AuthGuard(ref), UserGuard(ref)],
        ),

        AutoRoute(page: AboutUsRoute.page),
      ],
    ),

    // ================= USER FLOW =================
    AutoRoute(
      page: MatrimonyFormFlowRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserIdentityFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserPhysicalFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserCultureFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserEducationFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserEmploymentFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserFamilyFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserAddressFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserBiodataCheckRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserDetailRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserImageFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(page: SearchRoute.page, guards: [AuthGuard(ref), UserGuard(ref)]),
    AutoRoute(
      page: UserNotificationRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: MyProfileDetailRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: MyProfileRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserPaymentRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),

    AutoRoute(
      page: UserStatusRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserPaymentOrderHistoryRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserPaymentSuccessRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: AgentContactRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),

    AutoRoute(
      page: SupportTicketsRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: SupportTicketDetailRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: SupportTicketFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: ReviewFormRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),

    AutoRoute(
      page: ReviewDetailsRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),

    AutoRoute(
      page: MyReviewRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
    AutoRoute(
      page: UserAfterMarriagePaymentRoute.page,
      guards: [AuthGuard(ref), UserGuard(ref)],
    ),
  ];
}
