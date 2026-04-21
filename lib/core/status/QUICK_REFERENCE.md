# Quick Reference Guide - Status Management

## Quick Start

### Import
```dart
import 'package:arvika_marriage_bureau/core/status/status.dart';
```

### Basic Usage
```dart
final statusService = AppStatusService(ref);

// Set loading
statusService.setLoading(message: 'Loading...');

// Set success
statusService.setSuccess(message: 'Done!', data: result);

// Set error
statusService.setError(error);

// Check status
if (statusService.isLoading) { }
if (statusService.isAuthenticated) { }
if (statusService.isError) { }
```

## All Methods

| Method | Purpose |
|--------|---------|
| `setStatus(status, message, data)` | Set custom status |
| `setLoading(message)` | Set loading state |
| `setSuccess(message, data)` | Set success state |
| `setError(error, customMessage)` | Set error state |
| `setAuthenticating()` | Start auth process |
| `setAuthenticated(user)` | Auth successful |
| `setUnauthenticated()` | User logged out |
| `setAuthenticationFailed(reason)` | Auth failed |
| `setNetworkError(message)` | Network unavailable |
| `setSessionExpired()` | Session expired |
| `setSyncing(message)` | Start syncing |
| `setSyncCompleted(message)` | Sync done |
| `setSyncFailed(message)` | Sync failed |
| `setMaintenance(message)` | Maintenance mode |
| `handleAuthentication(future)` | Auto-manage auth flow |
| `handleSync(future)` | Auto-manage sync flow |
| `handleNetworkError(message)` | Handle network error |
| `handleLogout()` | Handle logout |
| `handleSessionExpired()` | Handle session expiry |
| `reset()` | Reset to initial |

## All Boolean Flags

```dart
statusService.isLoading          // true if loading
statusService.isSyncing          // true if syncing
statusService.isAuthenticated    // true if authenticated
statusService.isError            // true if error
statusService.isNetworkError     // true if network error
statusService.isSessionExpired   // true if session expired
```

## Provider Selectors

```dart
// Individual values
ref.watch(appStatusValueProvider)         // Just the enum
ref.watch(appStatusMessageProvider)       // Just the message
ref.watch(appStatusDataProvider)          // Just the data

// Booleans
ref.watch(isLoadingProvider)
ref.watch(isSyncingProvider)
ref.watch(isAuthenticatedProvider)
ref.watch(hasErrorProvider)
ref.watch(isNetworkErrorProvider)
ref.watch(isSessionExpiredProvider)

// Full data
ref.watch(appStatusFullProvider)          // Complete AppStatusData
```

## In Widgets

### Show loading spinner
```dart
if (ref.watch(isLoadingProvider))
  CircularProgressIndicator()
```

### Show error message
```dart
if (ref.watch(hasErrorProvider))
  Text(ref.watch(appStatusMessageProvider) ?? 'Error occurred')
```

### Show green success banner
```dart
if (ref.watch(appStatusValueProvider) == AppStatus.loaded)
  Container(color: Colors.green, child: Text('Loaded!'))
```

### Listen for changes
```dart
ref.listen(appStatusProvider, (prev, next) {
  if (next.status == AppStatus.error) {
    // Show error dialog
  }
});
```

## In Notifiers

### Wrap async operations
```dart
Future<void> getData() async {
  final status = AppStatusService(ref);
  
  try {
    status.setLoading();
    final data = await _fetch();
    status.setSuccess(data: data);
  } catch (e) {
    status.setError(e);
  }
}
```

### Auto-wrap with helpers
```dart
await statusService.handleAuthentication(
  () => firebaseAuth.signIn(email, password),
);

await statusService.handleSync(
  () => firestore.collection('users').get(),
);
```

## App-Wide Setup

### In main.dart
```dart
runApp(
  ProviderScope(
    child: AppStatusListener(
      onStatusChanged: (status) => print('Status: ${status.status}'),
      showSnackbar: true,
      child: MyApp(),
    ),
  ),
);
```

## Debug Widget

### Inline debug panel
```dart
Scaffold(
  body: Column(
    children: [
      StatusDebugPanel(expanded: false),
      // ... rest of UI
    ],
  ),
)
```

### Floating debug button (dev only)
```dart
StatusDebugButton(
  child: MyApp(),
)
```

## Common Patterns

### Auth Flow
```dart
statusService.setAuthenticating();
// -> User enters credentials
// -> Attempt login
statusService.setAuthenticated(user: user);
// or
statusService.setAuthenticationFailed(reason: 'Invalid credentials');
```

### Data Refresh
```dart
await statusService.handleSync(
  () => fetchData(),
  syncingMessage: 'Refreshing...',
);
```

### Error with Retry
```dart
try {
  statusService.setLoading();
  await operation();
  statusService.setSuccess();
} catch (e) {
  statusService.setError(e);
  // User can click "Retry" which calls this method again
}
```

### Network Detection
```dart
try {
  await operation();
} on SocketException {
  statusService.handleNetworkError();
} catch (e) {
  statusService.setError(e);
}
```

### Maintenance Check
```dart
if (await _checkMaintenance()) {
  statusService.setMaintenance(
    message: 'Update available. Please restart the app.',
  );
}
```

## Status Types

| Group | Statuses |
|-------|----------|
| **Loading** | `loading`, `authenticating`, `updating`, `syncing` |
| **Success** | `loaded`, `authenticated`, `updateCompleted`, `syncCompleted` |
| **Errors** | `error`, `authenticationFailed`, `syncFailed`, `networkError`, `sessionExpired` |
| **Special** | `initial`, `unauthenticated`, `maintenance` |

## Tips & Tricks

1. **Always use AppStatusService** - it's simpler than direct provider manipulation
2. **Use descriptive messages** - helps users understand what's happening
3. **Include error details** for debugging
4. **Listen selectively** - watch only what you need
5. **Use boolean flags** for quick state checks
6. **Combine with AsyncValue** for type-safe data + status
7. **Reset status** when navigating between screens
8. **Test status transitions** in unit tests
9. **Monitor performance** - use Riverpod DevTools
10. **Document custom statuses** if extending AppStatus enum

## Troubleshooting

**Status not updating?**
- Ensure you're reading from `AppStatusService(ref)`
- Check that provider is being watched correctly
- Verify ref is not stale

**UI not rebuilding?**
- Make sure you're watching the provider in build method
- Check for typos in provider names
- Clear hot reload cache if needed

**Memory leaks?**
- Call `statusService.reset()` when appropriate
- Avoid storing statusService in variables
- Always create fresh: `AppStatusService(ref)`

**Status changes too fast?**
- Add delays in simulated data if needed
- Debug with `debugShowCheckedModeBanner` to see rebuilds
- Use Riverpod DevTools to trace state changes
