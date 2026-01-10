import 'package:arvika_marriage_bureau/app/router/app_router.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/metrimony_state.dart';

abstract class MetrimonyRepository {
  Future<MatrimonyProfile> getMetrimonyProfile(String userId);
}

