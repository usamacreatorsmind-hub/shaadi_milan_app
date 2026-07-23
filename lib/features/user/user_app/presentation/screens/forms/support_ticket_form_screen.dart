import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../core/constants/app_labels.dart';
import '../../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../../data/repositories_impl/user_repo_impl.dart';
import '../../../domain/states/support_ticket.dart' show TicketPriority;
import '../../controllers/support_notifier.dart';

@RoutePage()
class SupportTicketFormScreen extends ConsumerStatefulWidget {
  const SupportTicketFormScreen({super.key});

  @override
  ConsumerState<SupportTicketFormScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState
    extends ConsumerState<SupportTicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  TicketPriority _selectedPriority = TicketPriority.medium;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _getCategories(BuildContext context) {
    return [
      AppLabels.catAccountIssues(context),
      AppLabels.catPaymentProblems(context),
      AppLabels.catProfileIssues(context),
      AppLabels.catTechSupport(context),
      AppLabels.catFeatureRequest(context),
      AppLabels.catOther(context),
    ];
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final userEntity = ref.read(currentUserProvider).value;

    if (userEntity == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLabels.userNotFound(context))));
      return;
    }

    await ref
        .read(supportNotifierProvider.notifier)
        .createTicket(
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: userEntity.uid,
          userName: userEntity.fullName.en,
          userEmail: userEntity.email,
          category: _selectedCategory,
          priority: _selectedPriority,
          agentId: userEntity.agentId.isEmpty ? "1234" : userEntity.agentId,
        );

    final state = ref.read(supportNotifierProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLabels.error(context, state.error.toString())),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLabels.ticketCreatedSuccess(context))),
      );
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifierProvider);
    final categories = _getCategories(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          MinimalAppBar(title: AppLabels.createSupportTicket(context)),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLabels.wereHereToHelp(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLabels.supportFormSubtitle(context),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: AppLabels.category(context),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) {
                          if (value == null)
                            return AppLabels.pleaseSelectCategory(context);
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority selection
                      Text(
                        AppLabels.priority(context),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: TicketPriority.values.map((priority) {
                          String label;
                          switch (priority) {
                            case TicketPriority.low:
                              label = AppLabels.low(context);
                              break;
                            case TicketPriority.medium:
                              label = AppLabels.medium(context);
                              break;
                            case TicketPriority.high:
                              label = AppLabels.high(context);
                              break;
                            case TicketPriority.urgent:
                              label = AppLabels.urgent(context);
                              break;
                          }
                          return ChoiceChip(
                            label: Text(label),
                            selected: _selectedPriority == priority,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedPriority = priority);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Subject field
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          labelText: AppLabels.subject(context),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.subject),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLabels.pleaseEnterSubject(context);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: AppLabels.description(context),
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppLabels.pleaseEnterDescription(context);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: state.isLoading ? null : _submitTicket,
                          icon: state.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            state.isLoading
                                ? AppLabels.submitting(context)
                                : AppLabels.submitTicket(context),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
