import '../states/support_ticket.dart';

abstract class SupportRepository {
  /// Create a new support ticket
  Future<String> createTicket(SupportTicket ticket);

  /// Fetch a single ticket by ID
  Future<SupportTicket> fetchTicket(String ticketId);

  /// Fetch all tickets for a specific user
  Future<List<SupportTicket>> fetchUserTickets(String userId);

  /// Watch all tickets for a specific user (real-time updates)
  Stream<List<SupportTicket>> watchUserTickets(String userId);

  /// Watch a specific ticket (real-time updates)
  Stream<SupportTicket> watchTicket(String ticketId);

  /// Update ticket status
  Future<void> updateTicketStatus(String ticketId, TicketStatus status);

  /// Add admin response to ticket
  Future<void> addAdminResponse(String ticketId, String response);

  /// Update ticket priority
  Future<void> updateTicketPriority(String ticketId, TicketPriority priority);

  /// Delete a ticket
  Future<void> deleteTicket(String ticketId);

  /// Fetch tickets by status
  Future<List<SupportTicket>> fetchTicketsByStatus(
    String userId,
    TicketStatus status,
  );

  /// Get ticket count for a user
  Future<int> getTicketCount(String userId);

  /// Get open ticket count for a user
  Future<int> getOpenTicketCount(String userId);
}
