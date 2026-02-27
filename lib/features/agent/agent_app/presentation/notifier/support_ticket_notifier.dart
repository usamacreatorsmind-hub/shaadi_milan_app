import 'dart:async';

import 'package:arvika_marriage_bureau/features/agent/agent_app/data/repositories_impl/support_repository_impl.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/support_ticket.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SupportTicketNotifier extends StateNotifier<AsyncValue<SupportTicket>> {
  final AgentSupportRepository _agentSupportRepository;

  StreamSubscription<SupportTicket>? _ticketSubscription;   
  
  SupportTicketNotifier(this._agentSupportRepository)
    : super(AsyncValue.loading());

  Future<void> updateTicketStatus({
    required String ticketId,
    required TicketStatus status,
    required String adminResponse,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _agentSupportRepository.updateTicketStatus(
        ticketId,
        status,
        adminResponse,
      );
      // Optionally, refetch the ticket or update the state optimistically
      // For now, we'll just set it back to data (assuming success)
      state = AsyncValue.data(
        state.value!.copyWith(status: status, adminResponse: adminResponse),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadSupportTicket(String ticketId) async {
    state = const AsyncValue.loading();
    try {
      final ticket = await _agentSupportRepository.readSupportTicket(ticketId);
      state = AsyncValue.data(ticket);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void watchSupportTicket(String ticketId) {
    state = const AsyncValue.loading();
    _ticketSubscription?.cancel(); // Cancel any previous subscription

    _ticketSubscription = _agentSupportRepository
        .watchSupportTicket(ticketId)
        .listen(
          (ticket) => state = AsyncValue.data(ticket),
          onError: (e, st) => state = AsyncValue.error(e, st),
        );
  }

  @override
  void dispose() {
    _ticketSubscription?.cancel();
    super.dispose();
  }
}

class SupportTicketsNotifier
    extends StateNotifier<AsyncValue<List<SupportTicket>>> {
  final AgentSupportRepository _agentSupportRepository;
  SupportTicketsNotifier(this._agentSupportRepository)
    : super(const AsyncValue.loading()) {
    _loadAllSupportTickets();
  }

  Stream<List<SupportTicket>>? _ticketsStream;
  StreamSubscription? _ticketsSubscription;

  void _loadAllSupportTickets() {
    _ticketsStream = _agentSupportRepository.getAllSupportTickets();
    _ticketsSubscription = _ticketsStream?.listen(
      (tickets) {
        state = AsyncValue.data(tickets);
      },
      onError: (e, st) {
        state = AsyncValue.error(e, st);
      },
    );
  }

  @override
  void dispose() {
    _ticketsSubscription?.cancel();
    super.dispose();
  }
}

final agentSupportTicketNotifierProvider =
    StateNotifierProvider<SupportTicketNotifier, AsyncValue<SupportTicket>>((
      ref,
    ) {
      return SupportTicketNotifier(ref.read(agentSupportRepositoryProvider));
    });

final agentSupportTicketsNotifierProvider =
    StateNotifierProvider<
      SupportTicketsNotifier,
      AsyncValue<List<SupportTicket>>
    >((ref) {
      return SupportTicketsNotifier(ref.read(agentSupportRepositoryProvider));
    });

final agentSupportTicketStreamProvider =
    StreamProvider.family<SupportTicket, String>((ref, ticketId) {
      final repository = ref.watch(agentSupportRepositoryProvider);
      return repository.watchSupportTicket(ticketId);
    });

final agentGetAllSupportTicketsProvider = StreamProvider<List<SupportTicket>>((
  ref,
) {
  final repository = ref.watch(agentSupportRepositoryProvider);
  return repository.getAllSupportTickets();
});
