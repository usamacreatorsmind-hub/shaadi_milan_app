# Centralized Status Management System

This system provides a comprehensive, centralized way to manage all application statuses and states in the ARVIKA Marriage Bureau app.

## Overview

The status management system provides:
- **AppStatus Enum**: Defines all possible application states
- **AppStatusData Class**: Holds status information with metadata
- **AppStatusNotifier**: StateNotifier for managing status changes
- **AppStatusProvider**: Riverpod providers for accessing status from anywhere
- **AppStatusService**: Easy-to-use service for managing status
- **UI Widgets**: Pre-built widgets for displaying status to users

## Architecture

```
AppStatus (Enum)
    ↓
AppStatusData (DTO with metadata)
    ↓
AppStatusNotifier (StateNotifier)
    ↓
AppStatusProvider (Riverpod Provider)
    ↓
UI Layer / Services
```

## Available Statuses

| Status | Purpose |
|--------|---------|
| `initial` | App startup state |
| `authenticating` | User authentication in progress |
| `authenticated` | User successfully authenticated |
| `authenticationFailed` | Auth process failed |
| `unauthenticated` | User logged out |
| `loading` | General loading state |
| `loaded` | Data loaded successfully |
| `error` | Error occurred |
| `networkError` | No internet connection |
| `syncing` | Syncing data with server |
| `syncCompleted` | Sync completed |
| `syncFailed` | Sync failed |
| `sessionExpired` | User session expired |
| `updating` | App is updating |
| `updateCompleted` | Update completed |
| `maintenance` | App in maintenance mode |

## Usage Examples

### 1. Basic Status Management with Service

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arvika_marriage_bureau/core/status/status.dart';

class MyFeature extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        final statusService = AppStatusService(ref);
        
        // Set loading
        statusService.setLoading(message: 'Fetching user data...');
        
        // Do work...
        try {
          await fetchUserData();
          statusService.setSuccess(message: 'Data loaded successfully');
        } catch (e) {
          statusService.setError(e, customMessage: 'Failed to load data');
        }
      },
      child: const Icon(Icons.refresh),
    );
  }
}
```

### 2. Handle Authentication Flow

```dart
final statusService = AppStatusService(ref);

// Handle login
await statusService.handleAuthentication(
  () => firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  ),
  successMessage: 'Login successful!',
);

// Handle logout
statusService.handleLogout();

// Handle session expiration
statusService.handleSessionExpired();
```

### 3. Handle Data Synchronization

```dart
final statusService = AppStatusService(ref);

await statusService.handleSync(
  () => firestore.collection('users').doc(userId).get(),
  syncingMessage: 'Syncing user profile...',
);
```

### 4. Listen to Status Changes

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to status changes
    ref.listen(appStatusProvider, (previous, next) {
      if (next.status == AppStatus.error) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(next.message ?? 'An error occurred'),
          ),
        );
      }
    });

    return Center(
      child: Text('Status: ${ref.watch(appStatusValueProvider)}'),
    );
  }
}
```

### 5. Display Status in UI

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final hasError = ref.watch(hasErrorProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: hasError
                ? const Text('Error loading data')
                : const Text('Data loaded'),
          ),
          
          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
```

### 6. Use AppStatusListener Widget

```dart
void main() {
  runApp(
    ProviderScope(
      child: AppStatusListener(
        onStatusChanged: (status) {
          print('Status changed to: ${status.status}');
        },
        showSnackbar: true,
        child: const MyApp(),
      ),
    ),
  );
}
```

### 7. Check Status Flags

```dart
final statusService = AppStatusService(ref);

if (statusService.isLoading) {
  // Show loading indicator
}

if (statusService.isAuthenticated) {
  // Show authenticated UI
}

if (statusService.isNetworkError) {
  // Show network error message
}

if (statusService.isSessionExpired) {
  // Show login prompt
}
```

## Integration with Existing Features

### In Auth Feature

```dart
class AuthNotifier extends StateNotifier<AsyncValue<User>> {
  AuthNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> login(String email, String password) async {
    final statusService = AppStatusService(ref);
    
    try {
      statusService.setAuthenticating();
      final user = await _loginUser(email, password);
      statusService.setAuthenticated(user: user);
      state = AsyncValue.data(user);
    } catch (e) {
      statusService.setAuthenticationFailed(reason: e.toString());
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

### In Data Sync Feature

```dart
Future<void> syncUserProfile() async {
  final statusService = AppStatusService(ref);
  
  await statusService.handleSync(
    () => fetchUserProfileFromServer(),
    syncingMessage: 'Updating profile...',
  );
}
```

### Error Handling

```dart
try {
  // Do something
} on NetworkException catch (e) {
  statusService.handleNetworkError(message: e.message);
} on SessionExpiredException catch (_) {
  statusService.handleSessionExpired();
} catch (e) {
  statusService.setError(e);
}
```

## Provider Selectors

Use specific providers to watch only what you need:

```dart
// Watch specific status value
final currentStatus = ref.watch(appStatusValueProvider);

// Watch error message
final errorMsg = ref.watch(appStatusMessageProvider);

// Watch additional data
final statusData = ref.watch(appStatusDataProvider);

// Watch boolean flags
final isLoading = ref.watch(isLoadingProvider);
final isSyncing = ref.watch(isSyncingProvider);
final isAuth = ref.watch(isAuthenticatedProvider);
final hasError = ref.watch(hasErrorProvider);
final isNetError = ref.watch(isNetworkErrorProvider);
final isSessionExp = ref.watch(isSessionExpiredProvider);

// Watch full status data
final fullStatus = ref.watch(appStatusFullProvider);
```

## Best Practices

1. **Use AppStatusService** for most operations - it's simpler than direct provider access
2. **Set appropriate messages** for user feedback
3. **Include error messages** for debugging
4. **Listen to specific statuses** you care about in your features
5. **Reset status** when appropriate to keep state clean
6. **Use boolean flags** for quick UI state checks
7. **Combine with error handling** for comprehensive error management
8. **Leverage AsyncValue** in notifiers for additional type safety

## File Structure

```
lib/core/status/
├── app_status.dart                 # Status enums and data classes
├── app_status_notifier.dart        # State notifier implementation
├── app_status_provider.dart        # Riverpod providers
├── app_status_service.dart         # Easy-to-use service
├── app_status_listener.dart        # Listener widget
├── status_widget.dart              # UI display widgets
└── status.dart                     # Exports all above
```

## Integration Checklist

- [ ] Import `status.dart` in `lib/core/` barrel export
- [ ] Wrap main app with `AppStatusListener`
- [ ] Use `AppStatusService` in all feature notifiers
- [ ] Update error handling to set status
- [ ] Add status checks in UI widgets
- [ ] Test status transitions in different scenarios
- [ ] Monitor performance of status provider
