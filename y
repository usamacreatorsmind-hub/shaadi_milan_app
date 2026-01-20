

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ---------- AGENTS (PUBLIC READ) ----------
    match /agents/{agentId} {
      allow read: if true;
      allow write: if false;
    }

    // ---------- USERS ----------
    match /users/{userId} {

      // ✅ Any authenticated user can READ any user
      allow read: if request.auth != null;

      // ✅ Only owner can CREATE & UPDATE
      allow create, update: if request.auth != null
                             && request.auth.uid == userId;

      // ❌ No delete
      allow delete: if false;
    }

    // ---------- MATRIMONY PROFILES ----------
    match /metrimony_profiles/{userId} {

      // ✅ Any authenticated user can READ
      allow read: if request.auth != null;

      // ✅ Only owner can CREATE & UPDATE
      allow create, update: if request.auth != null
                             && request.auth.uid == userId;

      // ❌ No delete
      allow delete: if false;
    }

    // ---------- USER STATUS ----------
    match /userStatus/{userId} {

      // ✅ Owner can read
      allow read: if request.auth != null
                  && request.auth.uid == userId;

      // ✅ Owner can create
      allow create: if request.auth != null
                    && request.auth.uid == userId;

      // ✅ Owner can update ONLY isProfileCreated
      allow update: if request.auth != null
                    && request.auth.uid == userId
                    && request.resource.data.diff(resource.data)
                         .changedKeys()
                         .hasOnly(['isProfileCreated']);

      // ❌ No delete
      allow delete: if false;
    }
    
    
  
    
    // firebase rule to read data from payment collection for current auhenticated user

//     match /payments/{userId} {
//       allow read: if request.auth != null && request.auth.uid == userId;
//       allow write: if request.auth != null && request.auth.uid == userId;
      
//     }

  match /payments/{agentId} {
    allow read: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.uid == resource.data.agentId
        );

      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.userId;

      allow update: if false;
      allow delete: if false;
    } 
  
    match /payments/{userId} {
    allow read: if request.auth != null &&
        (
          request.auth.uid == resource.data.userId ||
          request.auth.uid == resource.data.agentId
        );

      allow create: if request.auth != null &&
        request.auth.uid == request.resource.data.userId;

      allow update: if false;
      allow delete: if false;
    } 
  
  
    
     // Users: read/write own data
    match /users/{userId} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
    }

    // Orders: client can READ only their orders
    match /orders/{orderId} {
      allow read: if request.auth != null
        && request.auth.uid == resource.data.uid;

      allow write: if false; // backend only
    }

    // Amounts: READ ONLY pricing config
    match /amounts/{docId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
     match /supportTickets/{ticketId} {

  allow read: if request.auth != null
    && (
      request.query != null
      || resource.data.userId == request.auth.uid
      || resource.data.agentId == request.auth.uid
    );

  allow create: if request.auth != null
    && request.resource.data.userId == request.auth.uid;

  allow update: if request.auth != null
    && (
      resource.data.userId == request.auth.uid ||
      resource.data.agentId == request.auth.uid
    );

  allow delete: if false;
}


    
   match /reviews/{reviewId} {

      // ✅ Any authenticated user can read reviews
      allow read: if request.auth != null;

      // ✅ Only logged-in user can create a review
      // userId must match auth UID
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;

      // ✅ Only review owner can update or delete
      allow update, delete: if request.auth != null
        && request.auth.uid == resource.data.userId;
    }
    
    
    
    
      match /paymentCredentials/{docId} {
      allow read: if request.auth != null;
    }

    
    
    
    
  }
}
