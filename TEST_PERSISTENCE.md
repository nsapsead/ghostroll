# Testing Data Persistence

## Quick Test Steps

### 1. Restart Your App
- Stop the Flutter app completely
- Restart it with `flutter run -d chrome`
- This ensures it connects to the newly created database

### 2. Log In
- Make sure you're logged in with your email/password
- Check console for: `Firebase initialized successfully`
- Check console for: `Firestore offline persistence enabled` (or note if it fails - that's okay)

### 3. Save Profile Data
- Go to the **Profile** screen
- Fill in some test data:
  - First Name: "Test"
  - Surname: "User"
  - Weight: "75"
  - Height: "180"
  - Select a gender
- Click **Save** (or let auto-save trigger after 1 second)

### 4. Check Browser Console (F12)
Look for these success messages:

**When Saving:**
```
ProfileRepository: ========== SAVE OPERATION ==========
ProfileRepository: User ID: {your-user-id}
ProfileRepository: ✅ Write operation completed
ProfileRepository: ✅ Verified - document exists
ProfileRepository: Saved firstName: Test
ProfileRepository: Saved surname: User
```

**If you see errors instead:**
- `PERMISSION_DENIED` → Security rules issue
- `UNAVAILABLE` → Database connection issue
- `NOT_FOUND` → Database doesn't exist (but you just created it!)

### 5. Verify in Firestore Console
- Go to Firebase Console → Firestore Database → **Data** tab
- You should see:
  - Collection: `users`
  - Document ID: Your Firebase Auth UID (long string)
  - Fields: firstName, surname, weight, height, etc.

### 6. Test Persistence (Most Important!)
- **Close the app completely** (close Chrome tab)
- **Restart the app** (`flutter run -d chrome`)
- **Log in again** with the same account
- **Go to Profile screen**
- **Your data should be there!**

**Check console for:**
```
ProfileRepository: ========== LOAD OPERATION ==========
ProfileRepository: ✅ Document exists
ProfileRepository: firstName: Test
ProfileRepository: surname: User
```

## What Success Looks Like

✅ **Saving:**
- Console shows "✅ Write operation completed"
- Console shows "✅ Verified - document exists"
- Data appears in Firestore Console

✅ **Loading:**
- Console shows "✅ Document exists"
- Profile fields are populated automatically
- No errors in console

✅ **Persistence:**
- Data survives app restart
- Data survives browser close/reopen
- Data is visible in Firestore Console

## Troubleshooting

### Issue: Data saves but doesn't appear in Firestore Console
- **Wait a few seconds** - Firestore can take 1-2 seconds to update
- **Refresh the Firestore Console page**
- **Check you're looking at the right project**

### Issue: Data saves but doesn't load after restart
- **Check console logs** - look for load operation messages
- **Verify you're logged in** with the same account
- **Check User ID matches** - the ID when saving should match when loading

### Issue: Console shows errors
- **Permission Denied** → Check security rules are published
- **Database not found** → Verify database is created and in Native mode
- **Network error** → Check internet connection

### Issue: Auto-save not working
- **Wait 1 second** after typing - auto-save has a 1-second delay
- **Check console** for "Profile: Auto-saving profile data"
- **Try manual save** button instead

## Expected Console Output

**On App Start:**
```
Firebase initialized successfully
Firestore offline persistence enabled (or note about it)
```

**When Saving Profile:**
```
Profile: Saving profile data for user {uid}
ProfileRepository: ========== SAVE OPERATION ==========
ProfileRepository: User ID: {uid}
ProfileRepository: Data keys being saved: [firstName, surname, gender, weight, height]
ProfileRepository: ✅ Write operation completed
ProfileRepository: ✅ Verified - document exists
ProfileRepository: Saved document keys: [firstName, surname, gender, weight, height, ...]
```

**When Loading Profile:**
```
Profile: Loading profile data for user {uid}
ProfileRepository: ========== LOAD OPERATION ==========
ProfileRepository: User ID: {uid}
ProfileRepository: ✅ Document exists
ProfileRepository: Document keys: [firstName, surname, gender, weight, height, ...]
ProfileRepository: firstName: Test
ProfileRepository: surname: User
Profile: Loaded firstName: Test, surname: User
Profile: Profile data loaded successfully
```

## Next Steps After Testing

Once persistence is working:

1. ✅ Test with sessions (log a training session)
2. ✅ Test with goals (create a goal)
3. ✅ Test with calendar events
4. ✅ Verify everything persists across restarts

Your data should now persist! 🎉

