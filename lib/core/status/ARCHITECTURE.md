# Status Management System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           ARVIKA APP                                     │
│                                                                           │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │                    AppStatusListener (Root)                       │  │
│  │                   Wraps entire app + shows                        │  │
│  │                    snackbars on status change                     │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                  │                                       │
│         ┌────────────────────────┴────────────────────────────┐         │
│         │                                                      │         │
│    ┌────▼──────────────┐                            ┌────────▼────────┐ │
│    │   Feature A       │                            │   Feature B      │ │
│    │  (Auth, User)     │                            │  (Agent, Widget) │ │
│    │                   │                            │                  │ │
│    │  Uses:            │                            │  Uses:           │ │
│    │  AppStatusService │                            │  AppStatusService│ │
│    │                   │                            │                  │ │
│    └────┬──────────────┘                            └────┬─────────────┘ │
│         │                          ┌───────────────────┬─────────────┐   │
│         └──────────────────────────►│ AppStatusProvider│             │   │
│                                     │ (10 Riverpod     │             │   │
│                                     │  watches)        │             │   │
│                                     └────┬─────────────┘             │   │
│                                          │                           │   │
│                                     ┌────▼────────────────┐          │   │
│                                     │  AppStatusNotifier  │          │   │
│                                     │  (StateNotifier)    │          │   │
│                                     │  20+ convenience    │          │   │
│                                     │  methods            │          │   │
│                                     └────┬────────────────┘          │   │
│                                          │                           │   │
│                                     ┌────▼────────────┐             │   │
│                                     │  AppStatusData  │             │   │
│                                     │  {status,       │             │   │
│                                     │   message,      │             │   │
│                                     │   data,         │             │   │
│                                     │   timestamp}    │             │   │
│                                     └─────────────────┘             │   │
│                                                                      │   │
│                                     ┌──────────────────────────────┘   │
│                                     │                                   │
│         ┌───────────────────────────▼───────────────────────────┐      │
│         │           UI Widgets (watch providers)               │      │
│         │  • StatusMessageWidget                              │      │
│         │  • StatusDebugPanel                                 │      │
│         │  • Custom Widgets                                   │      │
│         └───────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Setting Status
```
Feature Code
    │
    ├─► statusService.setLoading()
    │        │
    ├─► statusService.setSuccess()
    │        │
    └─► statusService.setError()
            │
            ▼
    AppStatusService
            │
            ▼
    ref.read(appStatusProvider.notifier)
            │
            ▼
    AppStatusNotifier.setStatus()
            │
            ▼
    state = AppStatusData(...)
            │
            ▼
    ✅ Status Updated
```

### Reading Status
```
UI Widget / Feature Code
            │
            ├─ ref.watch(appStatusProvider)
            │          ▼
            │    Get Full State
            │
            ├─ ref.watch(isLoadingProvider)
            │          ▼
            │    Get Boolean Flag
            │
            ├─ ref.watch(appStatusValueProvider)
            │          ▼
            │    Get Just Enum
            │
            └─ ref.listen(appStatusProvider)
                       ▼
                   Listen for Changes
```

## Class Hierarchy

```
AppStatus (Enum)
  ├─ initial
  ├─ authenticating
  ├─ authenticated
  ├─ authenticationFailed
  ├─ unauthenticated
  ├─ loading
  ├─ loaded
  ├─ error
  ├─ networkError
  ├─ syncing
  ├─ syncCompleted
  ├─ syncFailed
  ├─ sessionExpired
  ├─ updating
  ├─ updateCompleted
  └─ maintenance

AppStatusData (DTO)
  ├─ status: AppStatus ✓
  ├─ message: String? (optional)
  ├─ data: dynamic? (optional)
  ├─ timestamp: DateTime (automatic)
  └─ copyWith(): AppStatusData

AppStatusNotifier (StateNotifier<AppStatusData>)
  ├─ setStatus(status, message, data)
  ├─ setLoading(message)
  ├─ setSuccess(message, data)
  ├─ setError(error, customMessage)
  ├─ setAuthenticating()
  ├─ setAuthenticated(user)
  ├─ setUnauthenticated()
  ├─ setAuthenticationFailed(reason)
  ├─ setNetworkError(message)
  ├─ setSessionExpired()
  ├─ setSyncing(message)
  ├─ setSyncCompleted(message)
  ├─ setSyncFailed(message)
  ├─ setMaintenance(message)
  ├─ handleAuthentication(future)
  ├─ handleSync(future)
  ├─ handleLogout()
  ├─ handleSessionExpired()
  ├─ handleNetworkError(message)
  ├─ reset()
  └─ Boolean Flags:
      ├─ isLoading
      ├─ isSyncing
      ├─ isAuthenticated
      ├─ isError
      ├─ isNetworkError
      └─ isSessionExpired

AppStatusService (Service Layer)
  ├─ Uses: AppStatusNotifier via WidgetRef
  ├─ Simplifies access with same methods
  └─ Recommended for feature code

AppStatusListener (ConsumerWidget)
  ├─ Listener at app root
  ├─ Shows snackbars on status change
  └─ Optional custom callbacks

StatusDebugPanel (Development)
  ├─ Shows current status
  ├─ Shows all boolean flags
  └─ Includes reset button

StatusDebugButton (Development)
  ├─ Floating button for quick access
  └─ Toggles StatusDebugPanel
```

## Provider Registration

```
Riverpod Providers (10 total)
│
├─ appStatusProvider
│  └─ StateNotifierProvider<AppStatusNotifier, AppStatusData>
│     └─ Main provider - read/write
│
├─ appStatusValueProvider
│  └─ Provider<AppStatus>
│     └─ Selector: just the enum
│
├─ appStatusMessageProvider
│  └─ Provider<String?>
│     └─ Selector: just the message
│
├─ appStatusDataProvider
│  └─ Provider<dynamic>
│     └─ Selector: just the data
│
├─ isLoadingProvider
│  └─ Provider<bool>
│     └─ Flag: status == loading
│
├─ isSyncingProvider
│  └─ Provider<bool>
│     └─ Flag: status == syncing
│
├─ isAuthenticatedProvider
│  └─ Provider<bool>
│     └─ Flag: status == authenticated
│
├─ hasErrorProvider
│  └─ Provider<bool>
│     └─ Flag: status == error
│
├─ isNetworkErrorProvider
│  └─ Provider<bool>
│     └─ Flag: status == networkError
│
├─ isSessionExpiredProvider
│  └─ Provider<bool>
│     └─ Flag: status == sessionExpired
│
└─ appStatusFullProvider
   └─ Provider<AppStatusData>
      └─ Full data object
```

## State Transitions

### Authentication Flow
```
initial
   │
   ▼
authenticating
   │
   ├─ Success ─► authenticated
   │
   └─ Failure ─► authenticationFailed
                   │
                   │ (Auto -> unauthenticated after logout)
                   ▼
              unauthenticated
```

### Data Loading Flow
```
initial
   │
   ▼
loading
   │
   ├─ Success ─► loaded
   │
   └─ Failure ─► error
                   │
                   ├─ Network Issue ─► networkError
                   │
                   └─ Other Error ─► error
```

### Sync Flow
```
loaded
   │
   ▼
syncing
   │
   ├─ Success ─► syncCompleted ─► loaded (auto)
   │
   └─ Failure ─► syncFailed ─► loaded (auto)
```

### Session Management
```
authenticated ─► sessionExpired
                      │
                      │ (Redirect to login)
                      ▼
                unauthenticated
```

## Integration Points

```
┌──────────────────┐
│   Feature Layer  │
│  (Notifiers)     │
└────────┬─────────┘
         │
         │ Uses AppStatusService
         │
┌────────▼─────────┐
│  Status Layer    │
│  (Core)          │
└────────┬─────────┘
         │
         │ Manages with AppStatusNotifier
         │
┌────────▼─────────┐
│   Riverpod       │
│   (State Mgmt)   │
└────────┬─────────┘
         │
         │ Watched by UI
         │
┌────────▼─────────┐
│   UI Layer       │
│  (Widgets)       │
└──────────────────┘
```

## Error Handling Strategy

```
Exception Caught
   │
   ├─ SocketException (Network)
   │  └─► statusService.handleNetworkError()
   │
   ├─ TimeoutException
   │  └─► statusService.setError(e, customMessage: "Request timeout")
   │
   ├─ FirebaseException
   │  ├─ Auth Failed
   │  │  └─► statusService.setAuthenticationFailed()
   │  │
   │  └─ Other
   │     └─► statusService.setError(e)
   │
   └─ Custom Exception
      └─► statusService.setError(e, customMessage: "Custom message")
```

## Performance Characteristics

```
Provider Watch     │ Re-renders
─────────────────────────────────
appStatusProvider  │ Entire status + listeners
isLoadingProvider  │ Only if loading changes
hasErrorProvider   │ Only if error changes
Other selectors    │ Only their specific value changes

Optimization:
• Watch specific providers, not full status
• Use boolean flags for simple checks
• Use value selector for just enum
• Listeners are async and won't block UI
```

## Thread/Async Safety

```
AppStatusService calls are:
├─ ✅ Async-safe (can await)
├─ ✅ Thread-safe (Riverpod handles)
├─ ✅ No race conditions (StateNotifier)
└─ ✅ No memory leaks (Riverpod cleanup)

Good Pattern:
try {
  await statusService.handleSync(
    () => fetchData()
  );
} catch (e) { }

Bad Pattern:
final status = AppStatusService(ref);
// ... later in different context
status.setLoading(); // ❌ Stale ref
```

## Testing Strategy

```
Unit Tests:
├─ Test AppStatusNotifier directly
├─ Test status transitions
├─ Test error handling
└─ Use ProviderContainer for isolation

Widget Tests:
├─ Test UI widgets with status
├─ Mock AppStatusService
└─ Verify UI updates on status change

Integration Tests:
├─ Test full feature flows
├─ Verify status updates propagate
└─ Check error recovery
```

---

This architecture ensures:
- ✅ Separation of concerns
- ✅ Easy testing
- ✅ Reactive UI updates
- ✅ Centralized state
- ✅ Scalability
- ✅ Maintainability
