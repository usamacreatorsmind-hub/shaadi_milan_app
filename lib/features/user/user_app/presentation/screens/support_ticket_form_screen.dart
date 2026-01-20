import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/domain/states/support_ticket.dart'
    show TicketPriority;
import 'package:arvika_marriage_bureau/features/user/user_app/presentation/controllers/support_notifier.dart';
import 'package:arvika_marriage_bureau/features/user/user_app/data/repositories_impl/user_repo_impl.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final List<String> _categories = [
    'Account Issues',
    'Payment Problems',
    'Profile Issues',
    'Technical Support',
    'Feature Request',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final userEntity = ref.read(currentUserProvider).value;

    if (userEntity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please log in again.')),
      );
      return;
    }

    await ref
        .read(supportNotifierProvider.notifier)
        .createTicket(
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: userEntity.uid,
          userName: userEntity.fullName,
          userEmail: userEntity.email,
          category: _selectedCategory,
          priority: _selectedPriority,
          agentId: userEntity.agentId.isEmpty ? "1234" : userEntity.agentId,
        );

    final state = ref.read(supportNotifierProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully!')),
      );
      context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifierProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const MinimalAppBar(title: 'Create Support Ticket'),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We\'re here to help!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tell us about your issue and we\'ll get back to you soon.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 32),

                      // Category dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                        validator: (value) {
                          if (value == null) return 'Please select a category';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority selection
                      const Text(
                        'Priority',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: TicketPriority.values.map((priority) {
                          return ChoiceChip(
                            label: Text(priority.displayName),
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
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subject),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
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
                            state.isLoading ? 'Submitting...' : 'Submit Ticket',
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
