# Agent Clients Screen - Full Implementation Guide

## Overview

The Agent Clients Screen has been fully implemented with complete separation of concerns using Clean Architecture principles.

---

## Architecture Layers

### 1. **Data Layer** (`data/`)

#### Data Source (`datasources/user_firestore.dart`)

- **Class**: `UserFirestoreImpl`
- **Responsibilities**:
  - Direct Firestore communication
  - Query users by agent ID
  - Fetch individual user by ID
  - Convert Firestore documents to UserEntity objects

**Key Methods**:

```dart
Future<List<UserEntity>> getUsersForAgent(String agentId)
  - Fetches all users where agentId matches
  - Handles document ID mapping

Future<UserEntity> getClientById(String userId)
  - Fetches a single user by their UID
  - Throws exception if user not found
```

#### Repository Implementation (`repositories_impl/user_repository_impl.dart`)

- **Class**: `UserRepositoryImpl`
- **Responsibilities**:
  - Implements the UserRepository interface
  - Delegates to UserFirestoreImpl
  - Provides abstraction over data sources

---

### 2. **Domain Layer** (`domain/`)

#### Repository Interface (`repositories/user_repository.dart`)

- **Class**: `UserRepository` (abstract)
- **Responsibilities**:
  - Defines contract for user data access
  - Technology-agnostic interface

**Methods**:

```dart
Future<UserEntity> getUserById(String userId)
Future<List<UserEntity>> getUsersForAgent(String agentId)
```

---

### 3. **Presentation Layer** (`presentation/`)

#### Notifiers (`notifier/user_nofier.dart`)

**UsersNotifier**

- Manages state for list of users
- Uses `AsyncValue<List<UserEntity>>`
- `getUsersForAgent(agentId)` - Fetches and caches users
- `resetUsers()` - Clears the list

**UserNotifier**

- Manages state for single user
- Uses `AsyncValue<UserEntity?>`
- `fetchUserById(uid)` - Fetches specific user
- `updateUser(user)` - Updates user in state
- `resetUser()` - Clears the user

#### Providers (`notifier/user_nofier.dart`)

```dart
// Data source provider
final userFirestoreProvider = Provider<UserFirestore>((ref) {
  return UserFirestoreImpl();
});

// Repository provider
final agentUserRepositoryProvider = Provider<UserRepository>((ref) {
  final userFirestore = ref.watch(userFirestoreProvider);
  return UserRepositoryImpl(userFirestore: userFirestore);
});

// Users list notifier provider
final agentUsersNotifierProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserEntity>>>((ref) {
  final userRepository = ref.watch(agentUserRepositoryProvider);
  return UsersNotifier(userRepository);
});

// Single user notifier provider
final agentUserNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserEntity?>>((ref) {
  final userRepository = ref.watch(agentUserRepositoryProvider);
  return UserNotifier(userRepository);
});
```

#### Screen (`screens/agent_clients_screen.dart`)

**AgentClientsScreen**

- ConsumerStatefulWidget that displays list of clients
- Fetches users on screen load
- Shows loading, error, and empty states
- Displays user cards with client information

**ClientCard Widget**

- Displays individual client information
- Shows:
  - User avatar with initials
  - Full name and email
  - Profile status (Active/Pending)
  - Phone number and role
  - User type

**Features**:

- Pull-to-refresh capability (via retry button)
- Error handling with detailed error messages
- Empty state with helpful messaging
- Loading indicator during data fetch
- Tap to view user details

---

## Data Flow

```
┌─────────────────────────┐
│  AgentClientsScreen     │
│  (Presentation)         │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  agentUsersNotifierProvider             │
│  (StateNotifierProvider)                │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  UsersNotifier                          │
│  (StateNotifier<AsyncValue<...>>)       │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  agentUserRepositoryProvider            │
│  (Provider<UserRepository>)             │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  UserRepositoryImpl                      │
│  (implements UserRepository)            │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  userFirestoreProvider                  │
│  (Provider<UserFirestore>)              │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  UserFirestoreImpl                       │
│  (Firestore data source)                │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  Firebase Firestore                     │
│  (Cloud database)                       │
└─────────────────────────────────────────┘
```

---

## Usage Example

### In Screen:

```dart
@override
void initState() {
  super.initState();
  // Fetch users when screen loads
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref
        .read(agentUsersNotifierProvider.notifier)
        .getUsersForAgent(widget.agentId);
  });
}

// Watch the users state
final usersAsync = ref.watch(agentUsersNotifierProvider);

// Handle different states
usersAsync.when(
  data: (users) => buildUsersList(users),
  loading: () => buildLoadingWidget(),
  error: (error, st) => buildErrorWidget(error),
);
```

### Fetch Single User:

```dart
ref
    .read(agentUserNotifierProvider.notifier)
    .fetchUserById(userId);
```

---

## State Management

### AsyncValue States

The implementation uses Riverpod's `AsyncValue` which provides three states:

1. **Loading** - Data is being fetched

   ```dart
   AsyncValue.loading()
   ```

2. **Data** - Data successfully loaded

   ```dart
   AsyncValue.data(users)
   ```

3. **Error** - An error occurred during fetch
   ```dart
   AsyncValue.error(error, stackTrace)
   ```

---

## Key Features

✅ **Full separation of concerns** - Data, Domain, and Presentation layers
✅ **Reactive state management** - Using Riverpod
✅ **Error handling** - Graceful error states and retry mechanism
✅ **Loading states** - Circular progress indicator during data fetch
✅ **Empty states** - Helpful message when no clients exist
✅ **Clean UI** - Professional card-based design
✅ **User-friendly** - Shows relevant user information at a glance

---

## Firebase Firestore Query

The implementation queries users with:

```
Collection: 'users'
Where: 'agentId' == agentId
```

Ensure your Firestore security rules allow agents to read their own users:

```firestore
match /users/{document=**} {
  allow read: if request.auth.uid == resource.data.agentId;
}
```

---

## Testing

To test the implementation:

1. Launch the app and navigate to Agent Clients screen
2. Verify users are loaded with correct agent ID filter
3. Check loading state appears during fetch
4. Verify error handling with invalid agent ID
5. Tap on a user card to load single user details

---

## File Structure

```
lib/features/agent/agent_app/
├── data/
│   ├── datasources/
│   │   └── user_firestore.dart (✓ Complete)
│   └── repositories_impl/
│       └── user_repository_impl.dart (✓ Complete)
├── domain/
│   └── repositories/
│       └── user_repository.dart (✓ Complete)
└── presentation/
    ├── notifier/
    │   └── user_nofier.dart (✓ Complete)
    └── screens/
        └── agent_clients_screen.dart (✓ Complete)
```

---

## Future Enhancements

- [ ] Add filtering/search functionality
- [ ] Add sorting options (by name, date, etc.)
- [ ] Implement pagination for large datasets
- [ ] Add real-time updates with Firestore snapshots
- [ ] Add client details/edit screen
- [ ] Add bulk operations (delete, archive, etc.)
- [ ] Add analytics and reporting

---

**Implementation Date**: January 10, 2026
**Status**: ✅ Complete and Ready to Use
