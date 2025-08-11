# Firebase Setup for GhostRoll Authentication

**⚠️ CRITICAL: Your app is currently crashing on TestFlight due to missing Firebase configuration!**

This guide will help you fix the current crashes and set up Firebase Authentication properly.

## Current Issues Causing TestFlight Crashes

1. **Missing real Firebase configuration** - All config files contain placeholder values
2. **Incorrect package names** - Firebase config doesn't match your actual app
3. **Missing iOS Firebase config** - GoogleService-Info.plist is missing or has wrong values

## Step 1: Fix Firebase Configuration (REQUIRED TO STOP CRASHES)

### Option A: Use FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Login to Firebase:
```bash
firebase login
```

3. Configure your project:
```bash
flutterfire configure
```

4. Select your Firebase project and platforms (iOS/Android)

This will automatically generate the correct `firebase_options.dart` file with real values.

### Option B: Manual Configuration

If you prefer manual setup, you need to replace ALL placeholder values in these files:

1. **`lib/firebase_options.dart`** - Replace all `YOUR_*` values
2. **`android/app/google-services.json`** - Replace all `YOUR_*` values  
3. **`ios/Runner/GoogleService-Info.plist`** - Replace all `YOUR_*` values

## Step 2: Get Real Firebase Configuration Values

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create one named `ghostroll-app`)
3. Go to Project Settings (gear icon)
4. Add your apps for each platform:

### Android Configuration
- Package name: `com.nick.ghostroll` ✅ (now matches your updated build.gradle)
- Download `google-services.json` and replace the existing file

### iOS Configuration  
- Bundle ID: `com.nick.ghostroll` ✅ (matches your Xcode project)
- Download `GoogleService-Info.plist` and add to Xcode project

## Step 3: Update Configuration Files

### Update firebase_options.dart
Replace these placeholder values with real ones from Firebase Console:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...', // Real API key from Firebase Console
  appId: '1:123456789012:android:abcdef...', // Real app ID
  messagingSenderId: '123456789012', // Real sender ID
  projectId: 'ghostroll-app', // Your actual project ID
  storageBucket: 'ghostroll-app.appspot.com', // Your actual bucket
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'AIzaSy...', // Real API key from Firebase Console
  appId: '1:123456789012:ios:abcdef...', // Real app ID
  messagingSenderId: '123456789012', // Real sender ID
  projectId: 'ghostroll-app', // Your actual project ID
  storageBucket: 'ghostroll-app.appspot.com', // Your actual bucket
  iosBundleId: 'com.nick.ghostroll', // This matches your actual iOS bundle ID
);
```

### Update google-services.json
Replace these values:

```json
{
  "project_info": {
    "project_number": "123456789012", // Real project number
    "project_id": "ghostroll-app", // Your actual project ID
    "storage_bucket": "ghostroll-app.appspot.com" // Your actual bucket
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef...", // Real app ID
        "android_client_info": {
          "package_name": "com.nick.ghostroll" // This matches your updated package name
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSy..." // Real API key
        }
      ]
    }
  ]
}
```

### Update GoogleService-Info.plist
Replace these values:

```xml
<key>API_KEY</key>
<string>AIzaSy...</string> <!-- Real iOS API key -->

<key>GCM_SENDER_ID</key>
<string>123456789012</string> <!-- Real sender ID -->

<key>BUNDLE_ID</key>
<string>com.nick.ghostroll</string> <!-- This matches your actual iOS bundle ID -->

<key>GOOGLE_APP_ID</key>
<string>1:123456789012:ios:abcdef...</string> <!-- Real iOS app ID -->
```

## Step 4: Verify Package Names Match

Ensure these match exactly between your app and Firebase config:

- **Android**: `com.nick.ghostroll` ✅ (now matches your updated build.gradle)
- **iOS**: `com.nick.ghostroll` ✅ (matches your Xcode project)

## Step 5: Test Firebase Connection

1. Run `flutter clean`
2. Run `flutter pub get`
3. Test on device/simulator
4. Check console logs for Firebase initialization success

## Step 6: Build for TestFlight

1. Update version in `pubspec.yaml` (e.g., `1.0.0+3`)
2. Build iOS app: `flutter build ios --release`
3. Archive in Xcode and upload to TestFlight

## Troubleshooting TestFlight Crashes

### Common Crash Causes
1. **Firebase not initialized** - Check `firebase_options.dart` has real values
2. **Missing config files** - Ensure both Android and iOS config files exist
3. **Package name mismatch** - Verify bundle IDs match exactly
4. **Invalid API keys** - All API keys must be real, not placeholders

### Debug Steps
1. Check Xcode console logs during crash
2. Verify Firebase initialization in `main.dart`
3. Test on physical device before TestFlight
4. Use Firebase Console to verify app registration

## Security Best Practices

1. **Never commit real Firebase config to public repos**
2. **Use environment variables for sensitive data**
3. **Rotate API keys regularly**
4. **Monitor Firebase Console for unusual activity**

## Next Steps After Fixing Crashes

1. Test authentication flow
2. Set up Firestore security rules
3. Configure push notifications
4. Add crash reporting
5. Set up analytics

---

**⚠️ IMPORTANT: Your app will continue to crash on TestFlight until you replace ALL placeholder values with real Firebase configuration!**

**✅ CORRECT BUNDLE IDs:**
- Android: `com.nick.ghostroll`
- iOS: `com.nick.ghostroll`

Need help? Check the [Firebase Flutter documentation](https://firebase.flutter.dev/) or [Firebase Console](https://console.firebase.google.com/). 