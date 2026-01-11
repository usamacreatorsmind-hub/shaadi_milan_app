# Payment Status Display Implementation

## Overview

This document describes the complete implementation of payment status display in the Agent Users Screen.

## Architecture Layers

### 1. **Data Layer**

#### Firestore Data Source (`data/datasources/user_payments_ds.dart`)

```dart
abstract class UserPaymentDs {
  Future<Payment?> getUserPayment({
    required String userId,
    required String agentId,
  });
  Future<List<Payment?>> getUsersPayment({required String agentId});
}

class UserpaymentsDSImpl implements UserPaymentDs
```

**Methods:**

- `getUserPayment()`: Fetch a single user's payment by userId and agentId
- `getUsersPayment()`: Fetch all payments for an agent
  - Queries Firestore collection 'payments'
  - Filters by agentId
  - Returns list of Payment objects
  - Includes error handling and logging

### 2. **Domain Layer**

#### Repository Interface (`domain/repositories/user_payments_repository.dart`)

```dart
abstract class UserPaymentsRepository {
  Future<Payment?> getUserPayment({
    required String agentId,
    required String userId,
  });
  Future<List<Payment?>> getUsersPayment({required String agentId});
}
```

### 3. **Data Implementation Layer**

#### Repository Implementation (`data/repositories_impl/user_payment_repository_impl.dart`)

```dart
class UserPaymentRepositoryImpl implements UserPaymentsRepository {
  final UserPaymentDs paymentsDs;

  // Delegates to data source
}
```

### 4. **Presentation Layer**

#### Notifier (`presentation/notifier/user_nofier.dart`)

```dart
class UsersPaymentsNotifier extends StateNotifier<AsyncValue<List<Payment?>>> {
  Future<void> getUsersPayment({required String agentId}) async {
    // Fetches payments from repository
    // Filters out null values
    // Updates state with valid payments
  }
}

final usersPaymentsNotifierProvider =
    StateNotifierProvider<UsersPaymentsNotifier, AsyncValue<List<Payment?>>>
```

#### Screen (`presentation/screens/agent_users_screen.dart`)

**Data Flow:**

1. `initState()` triggers two async operations:

   - `getUsersForAgent(agentId)` - Fetches users
   - `getUsersPayment(agentId: agentId)` - Fetches all agent's payments

2. **Payment Status Determination Logic:**

   ```dart
   if (userPayments.isEmpty) {
     statusToDisplay = 'Not Started'
   } else if (hasSuccess) {
     statusToDisplay = 'PAID'
   } else if (hasPending) {
     statusToDisplay = 'PENDING'
   } else {
     statusToDisplay = userPayments.first!.status
   }
   ```

3. **Status Display:**
   - Shows in UserCard with color coding
   - Green: PAID (successful payment)
   - Orange: PENDING (awaiting payment)
   - Grey: Not Started (no payments)
   - Red: FAILED (payment failed)

## Payment Status Model

**Payment State Fields:**

- `status`: PENDING | SUCCESS | FAILED
- `userId`: User's Firebase UID
- `agentId`: Agent's Firebase UID
- `amount`: Payment amount
- `createdAt`: Payment creation timestamp

## Firestore Collections Structure

```
payments/
  ├── document_id
  │   ├── userId: "user123"
  │   ├── agentId: "agent456"
  │   ├── status: "SUCCESS"
  │   ├── amount: 5000
  │   ├── createdAt: Timestamp
  │   └── ...
```

## Status Flow Diagram

```
initState()
    ├── getUsersForAgent(agentId)
    │   └── Updates: agentUsersNotifierProvider
    │
    └── getUsersPayment(agentId)
        └── Updates: usersPaymentsNotifierProvider
            ├── Queries: payments where agentId == provided agentId
            ├── Maps: Documents to Payment objects
            ├── Filters: Removes null values
            └── Returns: List<Payment?>

Build Widget
    ├── Watches: agentUsersNotifierProvider (users list)
    ├── Watches: usersPaymentsNotifierProvider (payments list)
    │
    └── For each user:
        ├── Filter payments: where p.userId == user.uid
        ├── Determine status: SUCCESS | PENDING | FAILED | NOT STARTED
        └── Display: UserCard with payment status
```

## UI Components

### UserCard

- Displays user information
- Shows payment status with color coding
- Action buttons: View Profile, Matrimony, Payment Details

### StatusTile

- Shows payment status with visual badge
- Color changes based on status:
  - Green (#2E7D32): PAID
  - Orange (#F57C00): PENDING
  - Red (#C62828): FAILED
  - Grey: Not Started

## Error Handling

- Console logging for debugging
- Error states caught and logged
- Null value filtering in data layer
- Try-catch blocks at multiple levels

## Performance Considerations

- Single Firestore query per page load (all payments for agent)
- In-memory filtering by userId (efficient for typical user lists)
- AsyncValue state management prevents redundant queries
- No real-time listeners (load-once approach)

## Testing Checklist

- [ ] Users load successfully
- [ ] Payments fetch without errors
- [ ] Status displays correctly for each user
- [ ] Colors change based on payment status
- [ ] Empty state shows "Not Started"
- [ ] Payment details screen navigates correctly
- [ ] Error states handled gracefully
