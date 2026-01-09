import 'package:arvika_marriage_bureau/features/auth/domain/states/agent_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories_impl/agent_repository_impl.dart';

class AgentEntityController extends StateNotifier<AsyncValue<AgentEntity>> {
  final AgentRepositoryImpl _agentRepository;
  final String _agentId;

  AgentEntityController(this._agentRepository, this._agentId)
    : super(const AsyncValue.loading()) {
    _fetchAgentEntity();
  }

  Future<void> _fetchAgentEntity() async {
    try {
      final agent = await _agentRepository.fetchAgentEntitybyAgentId(_agentId);
      state = AsyncValue.data(agent);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> approveAgent() async {
    // Implement approval logic here
    // For example, update agent status in the repository
    // state = state.whenData((agent) => agent.copyWith(status: 'approved'));
    print('Agent $_agentId approved');
  }

  Future<void> rejectAgent() async {
    // Implement rejection logic here
    // For example, update agent status in the repository
    // state = state.whenData((agent) => agent.copyWith(status: 'rejected'));
    print('Agent $_agentId rejected');
  }
}

final AgentEntityControllerProvider =
    StateNotifierProvider.family<
      AgentEntityController,
      AsyncValue<AgentEntity>,
      String
    >((ref, agentId) {
      final agentRepository = ref.read(agentRepositoryProvider);
      return AgentEntityController(
        agentRepository as AgentRepositoryImpl,
        agentId,
      );
    });
