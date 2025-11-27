# Firestore Security Rules Setup Guide

## ⚠️ CRITICAL: This is likely why your data isn't persisting!

Firestore **blocks all reads/writes by default** until you configure security rules. If your rules aren't set up correctly, your data will appear to save but actually be rejected by Firestore.

## How to Check Your Current Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** in the left menu
4. Click the **Rules** tab at the top
5. Check what rules are currently set

## Default Rules (BLOCKS EVERYTHING)

If you see this, **nothing will save**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;  // ❌ Blocks everything!
    }
  }
}
```

## Required Rules for Your App

Copy and paste these rules into the Firebase Console Rules editor:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can read/write their own profile document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Users can read/write their own sessions subcollection
      match /sessions/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own stats subcollection
      match /stats/{statId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own goals subcollection
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own calendar events subcollection
      match /calendar_events/{eventId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own instructors subcollection
      match /instructors/{instructorId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own clubs subcollection
      match /clubs/{clubId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // Users can read/write their own class sessions subcollection
      match /classSessions/{classSessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Temporary: Allow all reads/writes for testing (REMOVE IN PRODUCTION!)
    // Uncomment this ONLY if you want to test without authentication
    // match /{document=**} {
    //   allow read, write: if true;
    // }
  }
}
```

## Step-by-Step Setup

1. **Open Firebase Console**
   - Go to https://console.firebase.google.com/
   - Select your project

2. **Navigate to Firestore Rules**
   - Click **Firestore Database** → **Rules** tab

3. **Replace the rules**
   - Delete existing rules
   - Paste the rules above
   - Click **Publish**

4. **Verify the rules are active**
   - You should see a success message
   - The rules will be active immediately

## Testing After Setting Rules

1. **Save your profile** in the app
2. **Check the browser console** (F12)
   - Look for: `ProfileRepository: ✅ Write operation completed`
   - Look for: `ProfileRepository: ✅ Verified - document exists`
3. **Check Firestore Console**
   - Go to Firestore Database → Data tab
   - Look for collection `users`
   - Find your user document (ID = your Firebase Auth UID)
   - Verify the fields are there

## Firebase Free Tier Limits

The free tier (Spark Plan) has these limits:
- **Firestore Reads**: 50,000/day
- **Firestore Writes**: 20,000/day
- **Firestore Deletes**: 20,000/day
- **Storage**: 5GB
- **Bandwidth**: 1GB/day

**These limits should NOT prevent persistence** - they just limit daily usage. If you exceed limits, you'll get errors, but data will still save until you hit the limit.

## Common Issues

### Issue 1: Rules Not Published
- Make sure you click **Publish** after editing rules
- Rules take effect immediately after publishing

### Issue 2: Wrong User ID
- Check console logs for: `ProfileRepository: User ID: {some-id}`
- This should match your Firebase Auth UID
- You can find your UID in Firebase Console → Authentication → Users

### Issue 3: Not Authenticated
- Make sure you're logged in before saving
- Check console for: `Profile: Cannot save - no user available`

### Issue 4: Rules Syntax Error
- Firebase Console will show errors if rules are invalid
- Make sure all brackets are matched
- Make sure `rules_version = '2';` is at the top

## Quick Test Rules (Development Only)

If you want to test quickly without worrying about security:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;  // Any authenticated user can read/write
    }
  }
}
```

**⚠️ WARNING**: These rules allow any authenticated user to read/write any data. Only use for development/testing!

## Verify Rules Are Working

After setting rules, check the browser console when saving:

1. **Good signs:**
   - ✅ `ProfileRepository: ✅ Write operation completed`
   - ✅ `ProfileRepository: ✅ Verified - document exists`
   - ✅ No permission errors

2. **Bad signs:**
   - ❌ `PERMISSION_DENIED` errors
   - ❌ `ProfileRepository: ❌ WARNING - document does not exist after save!`
   - ❌ `Missing or insufficient permissions`

## Next Steps

1. **Set the security rules** (most important!)
2. **Test saving your profile**
3. **Check the console logs** for the detailed debug output
4. **Verify in Firestore Console** that data exists
5. **Restart the app** and verify data loads

If rules are set correctly and you still have issues, the console logs will show exactly what's happening.

