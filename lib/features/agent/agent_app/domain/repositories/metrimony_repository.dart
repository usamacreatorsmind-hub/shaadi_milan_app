import '../../../../../app/router/app_router.dart';
import '../../../../user/user_app/domain/states/metrimony_state.dart';

abstract class MetrimonyRepository {
  Future<MatrimonyProfile> getMetrimonyProfile(String userId);
}

