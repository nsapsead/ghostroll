# Firestore Schema Documentation

## Profile Data Structure

### Collection: `users`
### Document ID: `{userId}` (Firebase Auth UID)

### Profile Document Fields:

```javascript
{
  // Basic Information
  "firstName": "string",           // From firstName text field
  "surname": "string",             // From surname text field
  "gender": "string",               // One of: "Male", "Female", "Non-binary", "Prefer not to say"
  "dob": "string",                 // ISO 8601 date string (e.g., "1990-01-15T00:00:00.000")
  "weight": "string",              // Weight as text (e.g., "75" or "75 kg")
  "height": "string",              // Height as text (e.g., "180" or "180 cm")
  
  // Martial Arts Styles Selection
  "selectedStyles": [              // Array of selected style names
    "Brazilian Jiu-Jitsu (BJJ)",
    "Muay Thai",
    // ... etc
  ],
  
  // Belt Ranks (Map: styleName -> beltRank)
  "beltRanks": {
    "Brazilian Jiu-Jitsu (BJJ)": "Blue",
    "Muay Thai": "Beginner",
    // ... etc
  },
  
  // BJJ Stripes (Map: beltColor -> stripeCount)
  "bjjStripes": {
    "Blue": 2,
    "Purple": 0,
    // ... etc
  },
  
  // BJJ Instructor Status (Map: beltColor -> isInstructor)
  "bjjInstructor": {
    "Blue": false,
    "Purple": true,
    // ... etc
  },
  
  // Custom Belt Orders (Map: styleName -> array of belt objects)
  "customBeltOrders": {
    "Karate": [
      {"name": "White", "order": 1},
      {"name": "Yellow", "order": 2},
      // ... etc
    ]
  }
}
```

## Data Flow

### 1. Save Operation (Profile Screen → Firestore)

**Location:** `lib/screens/profile_screen.dart` → `_saveProfile()` or `_autoSaveProfile()`

**Data Collection:**
```dart
final data = {
  'firstName': _firstNameController.text,
  'surname': _surnameController.text,
  'gender': _selectedGender,
  'dob': _dateOfBirth?.toIso8601String(),
  'weight': _weightController.text,
  'height': _heightController.text,
  'beltRanks': _beltRanks,
  'bjjStripes': _bjjStripes,
  'bjjInstructor': _bjjInstructor,
  'customBeltOrders': _customBeltOrders,
};
```

**Save Path:**
```
ProfileScreen._saveProfile()
  ↓
ProfileRepository.updateProfile(userId, data)
  ↓
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set(data, SetOptions(merge: true))
```

### 2. Load Operation (Firestore → Profile Screen)

**Location:** `lib/repositories/profile_repository.dart` → `getProfile()`

**Load Path:**
```
ProfileScreen._loadProfileData()
  ↓
ProfileRepository.getProfile(userId)
  ↓
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get()
  ↓
Returns Map<String, dynamic> or {} if document doesn't exist
```

## Firestore Path Structure

```
users/
  └── {userId}/                    // Document ID = Firebase Auth UID
      ├── firstName: string
      ├── surname: string
      ├── gender: string
      ├── dob: string (ISO 8601)
      ├── weight: string
      ├── height: string
      ├── selectedStyles: array<string>
      ├── beltRanks: map<string, string>
      ├── bjjStripes: map<string, number>
      ├── bjjInstructor: map<string, boolean>
      └── customBeltOrders: map<string, array<map>>
```

## Related Collections

### Sessions (Subcollection)
```
users/
  └── {userId}/
      └── sessions/                 // Subcollection
          └── {sessionId}/          // Auto-generated document ID
              ├── date: timestamp
              ├── classType: string
              ├── focusArea: string
              └── ... (see Session model)
```

### Stats (Subcollection)
```
users/
  └── {userId}/
      └── stats/                    // Subcollection
          └── streak/                // Document
              ├── currentStreak: number
              ├── longestStreak: number
              ├── totalSessions: number
              ├── lastLogDate: timestamp
              └── achievements: array<string>
```

### Goals (Subcollection)
```
users/
  └── {userId}/
      └── goals/                    // Subcollection
          └── {goalId}/              // Document ID
              ├── title: string
              ├── description: string
              ├── category: string
              └── ... (see Goal model)
```

## Important Notes

1. **Document ID**: Uses Firebase Auth `user.uid` - this is critical for data persistence
2. **Merge Option**: Uses `SetOptions(merge: true)` to preserve existing fields
3. **Null Values**: Null values are removed before saving to avoid overwriting with null
4. **User ID Source**: `ref.read(currentUserProvider)` provides the `userId` from Firebase Auth

## Debugging Checklist

If data isn't persisting, check:

1. ✅ Is `user.uid` correct? (Check console logs: "Profile: Loading profile data for user {uid}")
2. ✅ Is data being sent? (Check: "Profile: Data being saved: {data}")
3. ✅ Is Firestore write succeeding? (Check: "ProfileRepository: Successfully updated profile in Firestore")
4. ✅ Is document verified? (Check: "ProfileRepository: Verified - document exists with X fields")
5. ✅ Are Firestore security rules allowing writes? (Check Firebase Console → Firestore → Rules)
6. ✅ Is data being loaded? (Check: "Profile: Retrieved data from Firestore: {keys}")

## Expected Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can read/write their own sessions
      match /sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own stats
      match /stats/{statId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own goals
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```



## Profile Data Structure

### Collection: `users`
### Document ID: `{userId}` (Firebase Auth UID)

### Profile Document Fields:

```javascript
{
  // Basic Information
  "firstName": "string",           // From firstName text field
  "surname": "string",             // From surname text field
  "gender": "string",               // One of: "Male", "Female", "Non-binary", "Prefer not to say"
  "dob": "string",                 // ISO 8601 date string (e.g., "1990-01-15T00:00:00.000")
  "weight": "string",              // Weight as text (e.g., "75" or "75 kg")
  "height": "string",              // Height as text (e.g., "180" or "180 cm")
  
  // Martial Arts Styles Selection
  "selectedStyles": [              // Array of selected style names
    "Brazilian Jiu-Jitsu (BJJ)",
    "Muay Thai",
    // ... etc
  ],
  
  // Belt Ranks (Map: styleName -> beltRank)
  "beltRanks": {
    "Brazilian Jiu-Jitsu (BJJ)": "Blue",
    "Muay Thai": "Beginner",
    // ... etc
  },
  
  // BJJ Stripes (Map: beltColor -> stripeCount)
  "bjjStripes": {
    "Blue": 2,
    "Purple": 0,
    // ... etc
  },
  
  // BJJ Instructor Status (Map: beltColor -> isInstructor)
  "bjjInstructor": {
    "Blue": false,
    "Purple": true,
    // ... etc
  },
  
  // Custom Belt Orders (Map: styleName -> array of belt objects)
  "customBeltOrders": {
    "Karate": [
      {"name": "White", "order": 1},
      {"name": "Yellow", "order": 2},
      // ... etc
    ]
  }
}
```

## Data Flow

### 1. Save Operation (Profile Screen → Firestore)

**Location:** `lib/screens/profile_screen.dart` → `_saveProfile()` or `_autoSaveProfile()`

**Data Collection:**
```dart
final data = {
  'firstName': _firstNameController.text,
  'surname': _surnameController.text,
  'gender': _selectedGender,
  'dob': _dateOfBirth?.toIso8601String(),
  'weight': _weightController.text,
  'height': _heightController.text,
  'beltRanks': _beltRanks,
  'bjjStripes': _bjjStripes,
  'bjjInstructor': _bjjInstructor,
  'customBeltOrders': _customBeltOrders,
};
```

**Save Path:**
```
ProfileScreen._saveProfile()
  ↓
ProfileRepository.updateProfile(userId, data)
  ↓
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .set(data, SetOptions(merge: true))
```

### 2. Load Operation (Firestore → Profile Screen)

**Location:** `lib/repositories/profile_repository.dart` → `getProfile()`

**Load Path:**
```
ProfileScreen._loadProfileData()
  ↓
ProfileRepository.getProfile(userId)
  ↓
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get()
  ↓
Returns Map<String, dynamic> or {} if document doesn't exist
```

## Firestore Path Structure

```
users/
  └── {userId}/                    // Document ID = Firebase Auth UID
      ├── firstName: string
      ├── surname: string
      ├── gender: string
      ├── dob: string (ISO 8601)
      ├── weight: string
      ├── height: string
      ├── selectedStyles: array<string>
      ├── beltRanks: map<string, string>
      ├── bjjStripes: map<string, number>
      ├── bjjInstructor: map<string, boolean>
      └── customBeltOrders: map<string, array<map>>
```

## Related Collections

### Sessions (Subcollection)
```
users/
  └── {userId}/
      └── sessions/                 // Subcollection
          └── {sessionId}/          // Auto-generated document ID
              ├── date: timestamp
              ├── classType: string
              ├── focusArea: string
              └── ... (see Session model)
```

### Stats (Subcollection)
```
users/
  └── {userId}/
      └── stats/                    // Subcollection
          └── streak/                // Document
              ├── currentStreak: number
              ├── longestStreak: number
              ├── totalSessions: number
              ├── lastLogDate: timestamp
              └── achievements: array<string>
```

### Goals (Subcollection)
```
users/
  └── {userId}/
      └── goals/                    // Subcollection
          └── {goalId}/              // Document ID
              ├── title: string
              ├── description: string
              ├── category: string
              └── ... (see Goal model)
```

## Important Notes

1. **Document ID**: Uses Firebase Auth `user.uid` - this is critical for data persistence
2. **Merge Option**: Uses `SetOptions(merge: true)` to preserve existing fields
3. **Null Values**: Null values are removed before saving to avoid overwriting with null
4. **User ID Source**: `ref.read(currentUserProvider)` provides the `userId` from Firebase Auth

## Debugging Checklist

If data isn't persisting, check:

1. ✅ Is `user.uid` correct? (Check console logs: "Profile: Loading profile data for user {uid}")
2. ✅ Is data being sent? (Check: "Profile: Data being saved: {data}")
3. ✅ Is Firestore write succeeding? (Check: "ProfileRepository: Successfully updated profile in Firestore")
4. ✅ Is document verified? (Check: "ProfileRepository: Verified - document exists with X fields")
5. ✅ Are Firestore security rules allowing writes? (Check Firebase Console → Firestore → Rules)
6. ✅ Is data being loaded? (Check: "Profile: Retrieved data from Firestore: {keys}")

## Expected Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can read/write their own sessions
      match /sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own stats
      match /stats/{statId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own goals
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```


