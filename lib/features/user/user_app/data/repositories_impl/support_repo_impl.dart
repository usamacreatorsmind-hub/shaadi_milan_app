import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/states/support_ticket.dart';
import '../datasources/firebase/support_firestore.dart';

class SupportRepoImpl implements SupportRepository {
  final SupportFirestoreDS _firestore;

  SupportRepoImpl(this._firestore);

  @override
  Future<String> createTicket(SupportTicket ticket) {
    return _firestore.createTicket(ticket);
  }

  @override
  Future<SupportTicket> fetchTicket(String ticketId) {
    return _firestore.fetchTicket(ticketId);
  }

  @override
  Future<List<SupportTicket>> fetchUserTickets(String userId) {
    return _firestore.fetchUserTickets(userId);
  }

  @override
  Stream<List<SupportTicket>> watchUserTickets(String userId) {
    return _firestore.watchUserTickets(userId);
  }

  @override
  Stream<SupportTicket> watchTicket(String ticketId) {
    return _firestore.watchTicket(ticketId);
  }

  @override
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) {
    return _firestore.updateTicketStatus(ticketId, status);
  }

  @override
  Future<void> addAdminResponse(String ticketId, String response) {
    return _firestore.addAdminResponse(ticketId, response);
  }

  @override
  Future<void> updateTicketPriority(String ticketId, TicketPriority priority) {
    return _firestore.updateTicketPriority(ticketId, priority);
  }

  @override
  Future<void> deleteTicket(String ticketId) {
    return _firestore.deleteTicket(ticketId);
  }

  @override
  Future<List<SupportTicket>> fetchTicketsByStatus(
    String userId,
    TicketStatus status,
  ) {
    return _firestore.fetchTicketsByStatus(userId, status);
  }

  @override
  Future<int> getTicketCount(String userId) {
    return _firestore.getTicketCount(userId);
  }

  @override
  Future<int> getOpenTicketCount(String userId) {
    return _firestore.getOpenTicketCount(userId);
  }
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final firestore = ref.watch(supportFirestoreProvider);
  return SupportRepoImpl(firestore);
});
