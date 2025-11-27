# Firestore Database Setup Guide

## Step 1: Create Firestore Database

1. **Go to Firebase Console**
   - Visit https://console.firebase.google.com/
   - Select your project

2. **Navigate to Firestore**
   - Click **Firestore Database** in the left sidebar
   - If you see "Get started" or "Create database", click it

3. **Choose Database Mode**
   - Select **Native mode** (NOT Datastore mode)
   - Native mode is the standard Firestore database
   - Click **Next**

4. **Choose Location**
   - Select a region closest to you (e.g., `us-central`, `europe-west`, `asia-southeast1`)
   - This affects latency - choose the closest one
   - Click **Enable**

5. **Wait for Creation**
   - Firebase will create your database (takes 1-2 minutes)
   - You'll see a success message when it's ready

## Step 2: Set Up Security Rules

Once the database is created:

1. **Go to Rules Tab**
   - In Firestore Database, click the **Rules** tab at the top

2. **Replace Default Rules**
   - Delete the default rules
   - Paste these rules:

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
  }
}
```

3. **Publish Rules**
   - Click **Publish** button
   - Rules take effect immediately

## Step 3: Verify Database is Ready

1. **Check Data Tab**
   - Click the **Data** tab in Firestore
   - You should see an empty database (no collections yet)
   - This is normal - collections will be created when you save data

2. **Check Rules Tab**
   - Verify your rules are published
   - Should show the rules you just pasted

## Step 4: Test in Your App

1. **Restart Your App**
   - Stop and restart your Flutter app
   - This ensures it connects to the new database

2. **Save Profile Data**
   - Go to Profile screen
   - Fill in some data (first name, surname, etc.)
   - Save the profile

3. **Check Browser Console (F12)**
   - Look for these success messages:
     - `ProfileRepository: ✅ Write operation completed`
     - `ProfileRepository: ✅ Verified - document exists`
     - `ProfileRepository: Saved firstName: {your name}`
   - If you see errors, check the error message

4. **Verify in Firestore Console**
   - Go back to Firebase Console → Firestore Database → Data tab
   - You should now see:
     - Collection: `users`
     - Document: Your user ID (Firebase Auth UID)
     - Fields: firstName, surname, etc.

## Step 5: Test Persistence

1. **Restart the App**
   - Close and reopen your app
   - Log in with the same account

2. **Check Profile Screen**
   - Your profile data should load automatically
   - Check console for: `ProfileRepository: ✅ Document exists`

## Troubleshooting

### Issue: "Database not found" or "Permission denied"
- **Solution**: Make sure you selected **Native mode** (not Datastore mode)
- **Solution**: Verify security rules are published

### Issue: Data saves but doesn't load
- **Solution**: Check that rules allow reads: `allow read, write: if ...`
- **Solution**: Verify you're logged in with the same account

### Issue: Can't see data in Firestore Console
- **Solution**: Make sure you're looking at the correct project
- **Solution**: Refresh the page
- **Solution**: Check that you're in the **Data** tab (not Rules or Indexes)

### Issue: Rules won't publish
- **Solution**: Check for syntax errors (missing brackets, commas)
- **Solution**: Make sure `rules_version = '2';` is at the top
- **Solution**: Firebase Console will show error messages

## Expected Database Structure

After saving data, your Firestore should look like:

```
users/
  └── {your-user-id}/          ← Document ID = Firebase Auth UID
      ├── firstName: "John"
      ├── surname: "Doe"
      ├── gender: "Male"
      ├── weight: "75"
      ├── height: "180"
      └── ... (other fields)
```

## Next Steps

Once the database is created and working:

1. ✅ Save your profile - it should persist now!
2. ✅ Log sessions - they'll be saved to `users/{userId}/sessions/`
3. ✅ Set goals - they'll be saved to `users/{userId}/goals/`
4. ✅ Everything should persist across app restarts

## Important Notes

- **Database Location**: Once set, you can't change the region (you'd need to create a new database)
- **Free Tier**: Includes 50K reads/day, 20K writes/day - plenty for development
- **Security**: Rules are critical - without them, nothing will save
- **Collections**: Created automatically when you first save data

Your data should now persist! 🎉

