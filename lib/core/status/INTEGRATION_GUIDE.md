# Status Management Integration Guide

This guide helps you integrate the centralized status management system into your existing ARVIKA features.

## Step 1: Add Status to Your Feature Notifier

### Before:
```dart
class UserNotifier extends StateNotifier<AsyncValue<User>> {
  UserNotifier(this.ref);

  final Ref ref;

  Future<void> getUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      final user = await _fetchUser(userId);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

### After:
```dart
class UserNotifier extends StateNotifier<AsyncValue<User>> {
  UserNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> getUser(String userId) async {
    final statusService = AppStatusService(ref);
    
    try {
      statusService.setLoading(message: 'Loading user profile...');
      final user = await _fetchUser(userId);
      statusService.setSuccess(message: 'Profile loaded', data: user);
      state = AsyncValue.data(user);
    } catch (e) {
      statusService.setError(e, customMessage: 'Failed to load profile');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

## Step 2: Update UI Widgets

### Before:
```dart
class UserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return userAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, __) => Text('Error: $err'),
      data: (user) => Text(user.name),
    );
  }
}
```

### After:
```dart
class UserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);
    final statusMessage = ref.watch(appStatusMessageProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Column(
      children: [
        // Show status message if available
        if (statusMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              statusMessage,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        
        // Main content
        userAsyncValue.when(
          loading: () => const CircularProgressIndicator(),
          error: (err, __) => Text('Error: $err'),
          data: (user) => Text(user.name),
        ),
      ],
    );
  }
}
```

## Step 3: Add Status Listener to Main App

Update your `main.dart`:

```dart
import 'package:arvika_marriage_bureau/core/status/status.dart';

void main() async {
  // ... initialization code ...
  
  runApp(
    ProviderScope(
      child: AppStatusListener(
        onStatusChanged: (status) {
          // Log status changes for debugging
          debugPrint('App Status: ${status.status}');
        },
        showSnackbar: true,
        child: const MyApp(),
      ),
    ),
  );
}
```

## Step 4: Common Scenarios

### Authentication Flow

```dart
class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this.ref) : super(const AsyncValue.initial());

  final Ref ref;

  Future<void> login(String email, String password) async {
    final statusService = AppStatusService(ref);

    try {
      statusService.setAuthenticating();
      final user = await _loginUser(email, password);
      statusService.setAuthenticated(user: user);
      state = AsyncValue.data(AuthState(user: user));
    } catch (e) {
      statusService.setAuthenticationFailed(reason: e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    final statusService = AppStatusService(ref);
    statusService.handleLogout();
    state = const AsyncValue.data(AuthState());
  }
}
```

### Data Refresh/Sync

```dart
Future<void> refreshUserProfile() async {
  final statusService = AppStatusService(ref);
  
  await statusService.handleSync(
    () => firestore.collection('users').doc(userId).get(),
    syncingMessage: 'Refreshing profile...',
  );
}
```

### Error Handling with Network Detection

```dart
Future<void> fetchData() async {
  final statusService = AppStatusService(ref);
  
  try {
    statusService.setLoading();
    final data = await _fetchFromServer();
    statusService.setSuccess(message: 'Data loaded');
  } on SocketException {
    statusService.handleNetworkError();
  } on TimeoutException {
    statusService.setError('Request timeout. Please try again.');
  } catch (e) {
    statusService.setError(e);
  }
}
```

### Maintenance Mode

```dart
Future<void> checkMaintenanceStatus() async {
  final statusService = AppStatusService(ref);
  
  final isMaintenance = await _checkServerStatus();
  if (isMaintenance) {
    statusService.setMaintenance(
      message: 'App is under maintenance. Please check back later.',
    );
  }
}
```

## Step 5: Feature-Specific Tips

### Agent Feature
```dart
class AgentNotifier extends StateNotifier<AsyncValue<List<Agent>>> {
  // ... 
  
  Future<void> loadAgents() async {
    final statusService = AppStatusService(ref);
    statusService.setLoading(message: 'Loading agents...');
    // ... rest of implementation
  }
}
```

### Auth Feature
```dart
Future<void> handleAuthStateChange() async {
  final statusService = AppStatusService(ref);
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    statusService.setUnauthenticated();
  } else {
    statusService.setAuthenticated(user: user);
  }
}
```

### User Feature
```dart
Future<void> updateUserProfile(UserProfile profile) async {
  final statusService = AppStatusService(ref);
  
  try {
    statusService.setLoading(message: 'Updating profile...');
    await _updateUserInFirebase(profile);
    statusService.setSuccess(message: 'Profile updated successfully');
  } catch (e) {
    statusService.setError(e);
  }
}
```

## Step 6: Testing Status Management

```dart
test('Status should update to loading', () {
  final container = ProviderContainer();
  final statusService = AppStatusService(container);
  
  statusService.setLoading();
  expect(statusService.isLoading, true);
});

test('Status should update to authenticated', () {
  final container = ProviderContainer();
  final statusService = AppStatusService(container);
  
  statusService.setAuthenticated(user: testUser);
  expect(statusService.isAuthenticated, true);
});
```

## Checklist

- [ ] Import `status.dart` in all affected features
- [ ] Update all feature notifiers to use `AppStatusService`
- [ ] Add `AppStatusListener` to main app
- [ ] Update UI widgets to show status messages
- [ ] Test authentication flow
- [ ] Test data sync flow
- [ ] Test error scenarios
- [ ] Test network error handling
- [ ] Verify loading states display correctly
- [ ] Monitor for any performance issues

## Debugging

To debug status changes, add logging to your app:

```dart
AppStatusListener(
  onStatusChanged: (status) {
    final log = [
      'Status: ${status.status}',
      'Message: ${status.message}',
      'Time: ${status.timestamp}',
    ].join(' | ');
    debugPrint(log);
  },
  child: const MyApp(),
)
```

Or use the Riverpod DevTools to inspect provider state changes.
