import 'package:shadi_milan/features/user/user_app/domain/states/support_ticket.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SupportFirestore {
  Stream<List<SupportTicket>> getAllSupportTicket();
  Stream<SupportTicket> watchSupportTicket(String id);
  Future<SupportTicket> readSupportTicket(String id);
  Future<void> updateTicketStatus(
    String ticketId,
    TicketStatus status,
    String adminResponse,
  );
}

class SupportFirestoreImpl implements SupportFirestore {
  final FirebaseFirestore _firestore;

  SupportFirestoreImpl(this._firestore);

  CollectionReference get _tickets => _firestore.collection('supportTickets');

  @override
  Future<void> updateTicketStatus(
    String ticketId,
    TicketStatus status,
    String adminResponse,
  ) async {
    await _tickets.doc(ticketId).update({
      'status': status.name,
      "adminResponse": adminResponse,
    });
  }

  @override
  Stream<List<SupportTicket>> getAllSupportTicket() {
    return _tickets
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SupportTicket.fromMap(data..['id'] = doc.id);
          }).toList(),
        );
  }

  @override
  Future<SupportTicket> readSupportTicket(String id) {
    return _tickets.doc(id).get().then((doc) {
      if (!doc.exists) {
        throw Exception('Support ticket with ID $id not found');
      }
      final data = doc.data() as Map<String, dynamic>;
      return SupportTicket.fromMap(data..['id'] = doc.id);
    });
  }

  @override
  Stream<SupportTicket> watchSupportTicket(String id) {
    return _tickets.doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Support ticket with ID $id not found');
      }
      final data = doc.data() as Map<String, dynamic>;
      return SupportTicket.fromMap(data..['id'] = doc.id);
    });
  }
}
