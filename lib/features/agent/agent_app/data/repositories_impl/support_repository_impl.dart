import 'package:shadi_milan/features/agent/agent_app/data/datasources/support_firestore.dart';
import 'package:shadi_milan/features/user/user_app/domain/states/support_ticket.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AgentSupportRepository {
  Stream<List<SupportTicket>> getAllSupportTickets();
  Stream<SupportTicket> watchSupportTicket(String id,  );
  Future<SupportTicket> readSupportTicket(String id);
  Future<void> updateTicketStatus(String ticketId, TicketStatus status, String adminResponse);
}

class AgentSupportRepositoryImpl implements AgentSupportRepository {
  final SupportFirestore _supportFirestore;

  AgentSupportRepositoryImpl(this._supportFirestore);

  @override
  Stream<List<SupportTicket>> getAllSupportTickets() {
    return _supportFirestore.getAllSupportTicket();
  }

  @override
  Stream<SupportTicket> watchSupportTicket(String id) {
    return _supportFirestore.watchSupportTicket(id);
  }

  @override
  Future<SupportTicket> readSupportTicket(String id) {
    return _supportFirestore.readSupportTicket(id);
  }

  @override
  Future<void> updateTicketStatus(String ticketId, TicketStatus status, String adminResponse) async {
    
    print('Updating ticket $ticketId status to ${status.name}');
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); 

    await _supportFirestore.updateTicketStatus(ticketId, status, adminResponse);               

  }
}

final agentSupportFirestoreProvider = Provider<SupportFirestore>((ref) {
  return SupportFirestoreImpl(FirebaseFirestore.instance);
});

final agentSupportRepositoryProvider = Provider<AgentSupportRepository>((ref) {
  return AgentSupportRepositoryImpl(ref.read(agentSupportFirestoreProvider));
});
