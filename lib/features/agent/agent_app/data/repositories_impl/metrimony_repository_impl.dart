import '../datasources/metrimony_firestore_ds.dart';
import '../../domain/repositories/metrimony_repository.dart';
import '../../../../user/user_app/domain/states/metrimony_state.dart';

class MetrimonyRepositoryImpl extends MetrimonyRepository {
  final MetrimonyFirestoreDs metrimonyFirestoreDs;

  MetrimonyRepositoryImpl(this.metrimonyFirestoreDs);

  @override
  Future<MatrimonyProfile> getMetrimonyProfile(String userId) {
    return metrimonyFirestoreDs.getMetrimonyProfile(userId).then((map) {
      return MatrimonyProfile.fromMap(map);
    });
  }
}
