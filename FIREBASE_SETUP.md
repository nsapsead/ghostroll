# Firebase Setup for GhostRoll Authentication

This guide will help you set up Firebase Authentication for your GhostRoll app.

## Prerequisites

- A Google account
- Flutter SDK installed
- Android Studio or VS Code

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter a project name: `ghostroll-app`
4. Choose whether to enable Google Analytics (recommended)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, click on "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Email/Password" authentication:
   - Click on "Email/Password"
   - Toggle "Enable"
   - Click "Save"

## Step 3: Set up Firestore Database

1. In your Firebase project, click on "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## Step 4: Configure Android App

1. In your Firebase project, click on the gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Scroll down to "Your apps" section
4. Click the Android icon (🤖)
5. Enter your Android package name: `com.example.martial_arts_journal`
6. Enter app nickname: `GhostRoll`
7. Click "Register app"
8. Download the `google-services.json` file
9. Replace the placeholder file in `android/app/google-services.json` with the downloaded file

## Step 5: Configure iOS App (Optional)

If you're developing for iOS:

1. In the same project settings, click the iOS icon (🍎)
2. Enter your iOS bundle ID: `com.example.martialArtsJournal`
3. Enter app nickname: `GhostRoll`
4. Click "Register app"
5. Download the `GoogleService-Info.plist` file
6. Add it to your iOS project in Xcode

## Step 6: Install Dependencies

Run the following command in your project directory:

```bash
flutter pub get
```

## Step 7: Test the Authentication

1. Run your app: `flutter run`
2. You should see the login screen
3. Try creating a new account
4. Test logging in and out

## Security Rules for Firestore

Update your Firestore security rules to allow authenticated users to read/write their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only read/write their own training sessions
    match /users/{userId}/sessions/{sessionId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Features Included

The authentication system includes:

- ✅ Email/Password registration and login
- ✅ Password strength validation
- ✅ Password reset functionality
- ✅ User profile creation in Firestore
- ✅ Secure sign out
- ✅ Authentication state management
- ✅ Beautiful dark theme UI
- ✅ Form validation and error handling
- ✅ Loading states and animations

## Troubleshooting

### Common Issues

1. **"google-services.json not found"**
   - Make sure you've downloaded and placed the file in `android/app/google-services.json`
   - Verify the package name matches your `build.gradle` file

2. **"Firebase not initialized"**
   - Ensure you've added the Firebase dependencies to `pubspec.yaml`
   - Check that `Firebase.initializeApp()` is called in `main.dart`

3. **"Authentication failed"**
   - Verify that Email/Password authentication is enabled in Firebase Console
   - Check that your app is properly configured with the correct package name

4. **"Permission denied"**
   - Update your Firestore security rules to allow authenticated access
   - Ensure users are properly authenticated before accessing data

### Getting Help

If you encounter issues:

1. Check the [Firebase documentation](https://firebase.google.com/docs)
2. Review the [Flutter Firebase plugin documentation](https://firebase.flutter.dev/)
3. Check the console logs for detailed error messages
4. Verify your Firebase project configuration

## Next Steps

After setting up authentication, you can:

1. Add more authentication providers (Google, Apple, etc.)
2. Implement user profile management
3. Add data persistence for training sessions
4. Set up push notifications
5. Add analytics and crash reporting

## Security Best Practices

1. **Never commit sensitive keys to version control**
   - Add `google-services.json` and `GoogleService-Info.plist` to `.gitignore`
   - Use environment variables for sensitive configuration

2. **Implement proper security rules**
   - Always validate user permissions in Firestore rules
   - Use Firebase Auth to verify user identity

3. **Handle errors gracefully**
   - Provide clear error messages to users
   - Log errors for debugging (but not sensitive data)

4. **Regular security updates**
   - Keep Firebase SDKs updated
   - Monitor Firebase Console for security alerts

---

Your GhostRoll app is now ready with a complete authentication system! 🥋👻 