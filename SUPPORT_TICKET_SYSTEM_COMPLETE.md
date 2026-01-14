# Support Ticket System - Complete Implementation Guide

## ✅ What's Been Completed

### 1. Domain Models (Enhanced) ✅
**File**: `lib/features/user/user_app/domain/states/support_ticket.dart`

**Features Added**:
- `TicketStatus` enum (open, inProgress, resolved, closed)
- `TicketPriority` enum (low, medium, high, urgent)
- Enhanced `SupportTicket` model with:
  - User information (name, email)
  - Priority and category
  - Attachments support
  - Timestamps (created, updated, resolved)
  - Admin response field
  - Assigned admin ID

### 2. Firestore Datasource (Complete) ✅
**File**: `lib/features/user/user_app/data/datasources/firebase/support_firestore.dart`

**Methods Available**:
- `createTicket()` - Create new ticket
- `fetchTicket()` - Get single ticket
- `fetchUserTickets()` - Get all user tickets
- `watchUserTickets()` - Real-time updates for all tickets
- `watchTicket()` - Real-time updates for single ticket
- `updateTicketStatus()` - Change ticket status
- `addAdminResponse()` - Add admin reply
- `updateTicketPriority()` - Change priority
- `deleteTicket()` - Delete ticket
- `fetchTicketsByStatus()` - Filter by status
- `getTicketCount()` - Total tickets count
- `getOpenTicketCount()` - Open tickets count

### 3. Repository (Complete) ✅
**Files**:
- `lib/features/user/user_app/domain/repositories/support_repository.dart`
- `lib/features/user/user_app/data/repositories_impl/support_repo_impl.dart`

**Features**:
- Abstract repository interface
- Complete implementation
- Provider for dependency injection

---

## 🚧 What Needs to Be Done

### 1. Update Support Notifier
**File**: `lib/features/user/user_app/presentation/controllers/support_notifier.dart`

Update the createTicket method to use new model:

```dart
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
```

Update the stream provider:

```dart
final userSupportTicketsStreamProvider =
    StreamProvider.family<List<SupportTicket>, String>((ref, userId) {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.watchUserTickets(userId); // Changed method name
});
```

### 2. Create Support Tickets List Screen

Create: `lib/features/user/user_app/presentation/screens/support_tickets_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../../app/router/app_router.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../domain/states/support_ticket.dart';
import '../controllers/support_notifier.dart';

@RoutePage()
class SupportTicketsListScreen extends ConsumerWidget {
  final String userId;

  const SupportTicketsListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(userSupportTicketsStreamProvider(userId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const ModernGradientAppBar(
            title: 'Support Tickets',
            subtitle: 'View and manage your tickets',
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: ticketsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyState(),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TicketCard(
                      ticket: tickets[index],
                      onTap: () => context.router.push(
                        SupportTicketDetailRoute(ticketId: tickets[index].id),
                      ),
                    ),
                    childCount: tickets.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.router.push(const CreateSupportTicketRoute()),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: _StatusIcon(status: ticket.status),
        title: Text(
          ticket.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityBadge(priority: ticket.priority),
                const SizedBox(width: 8),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusIcon extends StatelessWidget {
  final TicketStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        icon = Icons.info_outline;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        icon = Icons.pending_outlined;
        break;
      case TicketStatus.resolved:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TicketPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (priority) {
      case TicketPriority.low:
        color = Colors.green;
        break;
      case TicketPriority.medium:
        color = Colors.blue;
        break;
      case TicketPriority.high:
        color = Colors.orange;
        break;
      case TicketPriority.urgent:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No Support Tickets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a ticket to get help from our support team',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
```

### 3. Create Ticket Creation Screen

Create: `lib/features/user/user_app/presentation/screens/create_support_ticket_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../app/custom/custom_widgets/animated_app_bar.dart';
import '../../domain/states/support_ticket.dart';
import '../controllers/support_notifier.dart';

@RoutePage()
class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  ConsumerState<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState
    extends ConsumerState<CreateSupportTicketScreen> {
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

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    await ref.read(supportNotifierProvider.notifier).createTicket(
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          userId: user.uid,
          userName: user.fullName,
          userEmail: user.email,
          category: _selectedCategory,
          priority: _selectedPriority,
        );

    final state = ref.read(supportNotifierProvider);

    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket created successfully!')),
      );
      context.router.pop();
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
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.trim().length < 20) {
                            return 'Description must be at least 20 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isLoading ? null : _submitTicket,
                          child: state.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Submit Ticket'),
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
```

### 4. Update Router

Add these routes to your `app_router.dart`:

```dart
AutoRoute(
  page: SupportTicketsListRoute.page,
  path: '/support-tickets',
),
AutoRoute(
  page: CreateSupportTicketRoute.page,
  path: '/support-tickets/create',
),
AutoRoute(
  page: SupportTicketDetailRoute.page,
  path: '/support-tickets/:ticketId',
),
```

Then run: `flutter packages pub run build_runner build --delete-conflicting-outputs`

---

## 📋 Implementation Checklist

- [x] Enhanced domain models with enums
- [x] Complete Firestore datasource
- [x] Repository interface and implementation
- [ ] Update support notifier
- [ ] Create tickets list screen
- [ ] Create ticket creation screen
- [ ] Create ticket detail screen
- [ ] Update router
- [ ] Run build_runner
- [ ] Test complete flow

---

## 🎨 UI Features

### Tickets List Screen
- Modern gradient app bar
- Real-time ticket updates
- Status icons with colors
- Priority badges
- Empty state
- Floating action button

### Create Ticket Screen
- Category dropdown
- Priority selection chips
- Form validation
- Loading states
- Success/error feedback

### Ticket Detail Screen (To Be Created)
- Full ticket information
- Status timeline
- Admin responses
- Close ticket option

---

## 🔥 Firestore Collection Structure

```
support_tickets/
  {ticketId}/
    - id: string
    - userId: string
    - userName: string
    - userEmail: string
    - subject: string
    - description: string
    - status: string (open, in_progress, resolved, closed)
    - priority: string (low, medium, high, urgent)
    - category: string?
    - attachments: array<string>
    - createdAt: timestamp
    - updatedAt: timestamp?
    - resolvedAt: timestamp?
    - adminResponse: string?
    - assignedToId: string?
```

---

## 🚀 Next Steps

1. Update the support notifier as shown above
2. Create the screens (copy the code provided)
3. Update the router with the new routes
4. Run build_runner to generate router code
5. Link from profile screen or drawer
6. Test the complete flow
7. Add Firestore security rules
8. (Optional) Create ticket detail screen
9. (Optional) Add file attachments
10. (Optional) Add push notifications

---

## 📱 Integration Example

Add to user drawer or profile screen:

```dart
DrawerItem(
  icon: Icons.support_agent,
  title: 'Support Tickets',
  subtitle: 'Get help from our team',
  onTap: () {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId != null) {
      context.router.push(SupportTicketsListRoute(userId: userId));
    }
  },
),
```

---

**Status**: Ready for implementation!
**Estimated Time**: 1-2 hours for complete screens
**Complexity**: Medium

All foundation code is complete. Just need to create the UI screens and wire everything together!
