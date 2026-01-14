import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/support_ticket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/support_repo_impl.dart';
import '../../domain/repositories/support_repository.dart';

class SupportNotifier extends Notifier<SupportState> {
  @override
  SupportState build() => SupportState.initial();

  SupportRepository get _supportRepository =>
      ref.read(supportRepositoryProvider);

  Future<void> createTicket({
    required String subject,
    required String description,
    required String userId,
    required String userName,
    required String userEmail,
    String? category,
    TicketPriority priority = TicketPriority.medium,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newTicket = SupportTicket(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        createdAt: DateTime.now(),
      );

      final ticketId = await _supportRepository.createTicket(newTicket);
      final createdTicket = newTicket.copyWith(id: ticketId);

      state = state.copyWith(isLoading: false, supportTicket: createdTicket);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supportRepository.updateTicketStatus(ticketId, status);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetState() {
    state = SupportState.initial();
  }
}

final supportNotifierProvider = NotifierProvider<SupportNotifier, SupportState>(
  () => SupportNotifier(),
);

// Stream provider for real-time support tickets
final userSupportTicketsStreamProvider =
    StreamProvider.family<List<SupportTicket>, String>((ref, userId) {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.watchUserTickets(userId);
});

// Stream provider for single ticket
final supportTicketStreamProvider =
    StreamProvider.family<SupportTicket, String>((ref, ticketId) {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.watchTicket(ticketId);
});
