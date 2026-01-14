import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/support_ticket.dart';

final supportFirestoreProvider = Provider<SupportFirestoreDS>((ref) {
  return SupportFirestoreDS(FirebaseFirestore.instance);
});

class SupportFirestoreDS {
  final FirebaseFirestore _firestore;

  SupportFirestoreDS(this._firestore);

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _firestore.collection('supportTickets');

  /// Create a new support ticket
  Future<String> createTicket(SupportTicket ticket) async {
    try {
      final docRef = _tickets.doc();
      final ticketWithId = ticket.copyWith(id: docRef.id);
      await docRef.set(ticketWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create support ticket: $e');
    }
  }

  /// Fetch a single ticket by ID
  Future<SupportTicket> fetchTicket(String ticketId) async {
    try {
      final doc = await _tickets.doc(ticketId).get();
      if (!doc.exists) {
        throw Exception('Support ticket not found');
      }
      return SupportTicket.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch support ticket: $e');
    }
  }

  /// Fetch all tickets for a specific user
  Future<List<SupportTicket>> fetchUserTickets(String userId) async {
    try {
      final querySnapshot = await _tickets
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SupportTicket.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user tickets: $e');
    }
  }

  /// Watch all tickets for a specific user (real-time updates)
  Stream<List<SupportTicket>> watchUserTickets(String userId) {
    return _tickets
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromMap(doc.data()))
              .toList(),
        );
  }

  /// Watch a specific ticket (real-time updates)
  Stream<SupportTicket> watchTicket(String ticketId) {
    return _tickets.doc(ticketId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Support ticket not found');
      }
      return SupportTicket.fromMap(doc.data()!);
    });
  }

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      await _tickets.doc(ticketId).update({
        'status': status.value,
        'updatedAt': Timestamp.now(),
        if (status == TicketStatus.resolved || status == TicketStatus.closed)
          'resolvedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update ticket status: $e');
    }
  }

  /// Update ticket with admin response
  Future<void> addAdminResponse(String ticketId, String response) async {
    try {
      await _tickets.doc(ticketId).update({
        'adminResponse': response,
        'status': TicketStatus.inProgress.value,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to add admin response: $e');
    }
  }

  /// Update ticket priority
  Future<void> updateTicketPriority(
    String ticketId,
    TicketPriority priority,
  ) async {
    try {
      await _tickets.doc(ticketId).update({
        'priority': priority.name,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update ticket priority: $e');
    }
  }

  /// Delete a ticket
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _tickets.doc(ticketId).delete();
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }

  /// Fetch tickets by status
  Future<List<SupportTicket>> fetchTicketsByStatus(
    String userId,
    TicketStatus status,
  ) async {
    try {
      final querySnapshot = await _tickets
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.value)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SupportTicket.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tickets by status: $e');
    }
  }

  /// Get ticket count for a user
  Future<int> getTicketCount(String userId) async {
    try {
      final querySnapshot = await _tickets
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get ticket count: $e');
    }
  }

  /// Get open ticket count for a user
  Future<int> getOpenTicketCount(String userId) async {
    try {
      final querySnapshot = await _tickets
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: TicketStatus.open.value)
          .count()
          .get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get open ticket count: $e');
    }
  }
}
