# Firestore Security Rules (Authoritative Copy)

Use this file as the single source of truth for your Firestore rules.  
Copy the block below into Firebase Console → Firestore Database → **Rules** and click **Publish**.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── Per-user data (documents that live under users/{userId}) ────────────────
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /stats/{statId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      // NOTE: collection name is calendar_events (with underscore)
      match /calendar_events/{eventId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /instructors/{instructorId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /clubs/{clubId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /classSessions/{classSessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // ── Top-level collections used by clubs & community features ───────────────
    match /classSessions/{sessionId} {
      allow read, write: if request.auth != null;
    }

    match /classNotes/{noteId} {
      allow read, write: if request.auth != null;
    }

    match /clubs/{clubId} {
      allow read, write: if request.auth != null;
    }

    match /clubMembers/{memberId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Why these paths?
| Collection / Path | Used for | Location in code |
| --- | --- | --- |
| `users/{userId}` + subcollections | Profile, sessions, streaks, goals, calendar, instructors | `lib/repositories/*_repository.dart` |
| `classSessions` | Community class schedule | `lib/repositories/class_session_repository.dart` |
| `classNotes` | Notes linked to classes | `lib/repositories/class_session_repository.dart` |
| `clubs` | Club metadata and search | `lib/repositories/club_repository.dart` |
| `clubMembers` | Membership records | `lib/repositories/club_repository.dart` |

Adjust the `allow read/write` conditions if you need more granular control (e.g., only club admins can edit Club data), but this template will unblock all current app features.

