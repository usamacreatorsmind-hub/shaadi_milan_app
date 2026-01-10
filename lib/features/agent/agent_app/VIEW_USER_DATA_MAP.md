# View User Screen - Complete Data Reference

## Data Display Sections

### 📱 Header Section

```
┌─────────────────────────────────────┐
│     Deep Purple Background          │
│                                     │
│          [Avatar Circle]            │
│          John Doe                   │
│       john@example.com              │
│                                     │
└─────────────────────────────────────┘
```

**Fields Displayed:**

- Profile Image (circular, 100x100px)
- Full Name
- Email Address

---

### 📊 Status Cards Section

```
┌──────────────────────────────────────────────┐
│  ✓ Profile Status    |    ❤️ Wishlists     │
│  Created/Pending     |    Count: 5          │
└──────────────────────────────────────────────┘
```

**Fields Displayed:**

- `isProfileCreated` → Status indicator (Created/Pending)
- `wishlists.length` → Wishlist count with heart icon

---

### 📞 Contact Information

```
┌────────────────────────────────────┐
│  📧 Contact Information            │
│  ☎️ Phone: +91 XXXXX XXXXX        │
│  📧 Email: john@example.com        │
└────────────────────────────────────┘
```

**Fields Displayed:**

- `phone` - Phone number (or "Not provided")
- `email` - Email address

---

### 👤 Account Information

```
┌────────────────────────────────────┐
│  👤 Account Information            │
│  🏷️ User ID: uid_12345            │
│  ✓ Role: User/Admin/Agent         │
│  📂 User Type: Client              │
│  ⚤ Gender: Male/Female (optional) │
└────────────────────────────────────┘
```

**Fields Displayed:**

- `uid` - Unique user identifier
- `role` - User role (or "User")
- `userType` - Account type (or "Not specified")
- `gender` - Gender (optional, only if available)

---

### 💍 Matrimony Information

```
┌────────────────────────────────────┐
│  💍 Matrimony Information          │
│  🔐 Matrimony ID: metro_001        │
│  📌 Profile ID: prof_456           │
│  👨 Agent ID: agent_789            │
└────────────────────────────────────┘
```

**Fields Displayed:**

- `metrimonyId` - Matrimony profile ID (or "Not assigned")
- `profileId` - Associated profile ID (or "Not assigned")
- `agentId` - Agent who manages this user (or "Not assigned")

---

### 📅 Activity Information

```
┌────────────────────────────────────┐
│  📅 Activity                       │
│  📆 Created At: 15/01/2026 14:30   │
│  ⏰ Last Seen: 10/01/2026 09:15    │
└────────────────────────────────────┘
```

**Fields Displayed:**

- `createdAt` - Account creation timestamp (formatted)
- `lastSeen` - Last activity timestamp (formatted)
- Shows "Not available" for empty timestamps

---

### 📋 Wishlists (Conditional)

```
┌────────────────────────────────────┐
│  📋 Wishlists                      │
│  [1] wishlist_id_001               │
│  [2] wishlist_id_002               │
│  [3] wishlist_id_003               │
│  ...                               │
└────────────────────────────────────┘
```

**Only shows if `wishlists.isNotEmpty`**
**Fields Displayed:**

- `wishlists` - List of wishlist profile IDs
- Each displayed with numbered badge

---

### 🎯 Action Buttons

```
┌────────────────────────────────────┐
│  [☎️ Call              ]            │
│  [💬 Message           ]            │
│  [📦 Archive           ]            │
└────────────────────────────────────┘
```

**Actions Available:**

- Call - Initiate contact
- Message - Send message
- Archive - Archive user profile

---

## Complete Data Mapping

| Display Section | Data Field         | Type         | Fallback                  |
| --------------- | ------------------ | ------------ | ------------------------- |
| Header Avatar   | `profileImageUrl`  | String       | Person icon               |
| Header Name     | `fullName`         | String       | -                         |
| Header Email    | `email`            | String       | -                         |
| Profile Status  | `isProfileCreated` | Boolean      | "Pending"                 |
| Wishlists Count | `wishlists.length` | Int          | 0                         |
| Phone           | `phone`            | String       | "Not provided"            |
| Email (again)   | `email`            | String       | -                         |
| User ID         | `uid`              | String       | -                         |
| Role            | `role`             | String       | "User"                    |
| User Type       | `userType`         | String       | "Not specified"           |
| Gender          | `gender`           | String?      | (hidden if empty)         |
| Matrimony ID    | `metrimonyId`      | String       | "Not assigned"            |
| Profile ID      | `profileId`        | String       | "Not assigned"            |
| Agent ID        | `agentId`          | String       | "Not assigned"            |
| Created At      | `createdAt`        | DateTime     | "Not available"           |
| Last Seen       | `lastSeen`         | DateTime     | "Not available"           |
| Wishlists List  | `wishlists[]`      | List<String> | (section hidden if empty) |

---

## State Management

### Loading State

```
⏳ Loading User...
[Circular Progress Indicator]
```

### Error State

```
❌ Error Loading User
[Error message details]
[Retry Button]
```

### Not Found State

```
😔 User Not Found
[Person icon]
```

### Success State

```
[Full user profile displayed]
[All sections visible/conditional]
```

---

## Color & Icon Reference

### Section Icons

- 📧 Contact Information: `Icons.contact_mail`
- 👤 Account Information: `Icons.account_box`
- 💍 Matrimony Information: `Icons.favorite_border`
- 📅 Activity: `Icons.history`
- 📋 Wishlists: `Icons.list`

### Detail Row Icons

- ☎️ Phone: `Icons.phone`
- 📧 Email: `Icons.email`
- 🏷️ ID: `Icons.badge`
- ✓ Role: `Icons.verified_user`
- 📂 Type: `Icons.category`
- ⚤ Gender: `Icons.wc`
- 🔐 ID: `Icons.fingerprint`
- 📌 ID: `Icons.person_pin`
- 👨 Agent: `Icons.supervisor_account`
- 📆 Date: `Icons.calendar_today`
- ⏰ Time: `Icons.access_time`

### Button Colors

- Call: Deep Purple (Colors.deepPurple)
- Message: Teal (Colors.teal)
- Archive: Outlined (secondary)

---

## Date Time Format

**Format**: `dd/MM/yyyy HH:mm`
**Example**: `10/01/2026 09:15`
**Condition**: Shows "Not available" if millisecondsSinceEpoch == 0

---

## Responsive Layout

- **Width**: Full screen width
- **Padding**: 16-24px horizontal, 0-32px vertical
- **Card Styling**: BorderRadius 16, Elevation 2
- **Avatar Size**: 100x100 circle
- **Status Icons**: 32px size
- **Icon/Text Spacing**: 8-12px

---

**All Data Properly Mapped & Displayed ✅**
