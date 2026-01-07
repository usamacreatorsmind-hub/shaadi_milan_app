import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories_impl/agent_repository_impl.dart';
import '../../domain/states/agent_state.dart';

class AgentProfileController extends StateNotifier<AsyncValue<AgentProfile>> {
  final AgentRepositoryImpl _agentRepository;
  final String _agentId;

  AgentProfileController(this._agentRepository, this._agentId)
    : super(const AsyncValue.loading()) {
    _fetchAgentProfile();
  }

  Future<void> _fetchAgentProfile() async {
    try {
      final agentProfile = await _agentRepository.fetchAgentProfilebyAgentId(
        _agentId,
      );
      state = AsyncValue.data(agentProfile);
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

final agentProfileControllerProvider =
    StateNotifierProvider.family<
      AgentProfileController,
      AsyncValue<AgentProfile>,
      String
    >((ref, agentId) {
      final agentRepository = ref.read(agentRepositoryProvider);
      return AgentProfileController(
        agentRepository as AgentRepositoryImpl,
        agentId,
      );
    });
