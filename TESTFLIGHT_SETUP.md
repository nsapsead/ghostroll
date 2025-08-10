# TestFlight Beta Testing Setup Guide

## 🚀 **Prerequisites**

### **1. Apple Developer Account**
- **Apple Developer Program membership** ($99/year) - Required for TestFlight
- **App Store Connect access** - Where you'll manage TestFlight builds

### **2. Current App Configuration** ✅
- **Bundle ID**: `com.nick.ghostroll` ✅ (Already configured)
- **App Name**: GhostRoll ✅
- **Version**: 1.0.0+2 ✅ (Updated for TestFlight)
- **iOS Deployment Target**: iOS 13.0+ ✅
- **Required Permissions**: All usage descriptions configured ✅
- **App Icon**: 1024x1024 icon available ✅
- **Privacy Policy**: Created ✅

## 📱 **Step-by-Step TestFlight Setup**

### **Step 1: App Store Connect Setup**

1. **Create App Record**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - Click "My Apps" → "+" → "New App"
   - Fill in app details:
     - **Name**: GhostRoll
     - **Bundle ID**: `com.nick.ghostroll`
     - **SKU**: `ghostroll2024` (or any unique identifier)
     - **User Access**: Full Access

2. **App Information**:
   - **Primary Language**: English
   - **Category**: Health & Fitness
   - **Content Rights**: No (unless you have third-party content)
   - **Privacy Policy URL**: `https://ghostroll.app/privacy` (or your actual URL)

### **Step 2: Build Configuration**

1. **Current Version** ✅:
   ```yaml
   # pubspec.yaml
   version: 1.0.0+2  # Format: version+build_number
   ```

2. **Build for Release**:
   ```bash
   # Clean and build
   flutter clean
   flutter pub get
   
   # Build iOS release
   flutter build ios --release
   ```

### **Step 3: Archive and Upload**

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Archive Process**:
   - Select "Any iOS Device (arm64)" as target
   - Go to Product → Archive
   - Wait for archive to complete

3. **Upload to App Store Connect**:
   - In Organizer, select your archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"
   - Follow the upload process

### **Step 4: TestFlight Configuration**

1. **In App Store Connect**:
   - Go to your app → TestFlight tab
   - Wait for build to process (5-30 minutes)
   - Add build to testing

2. **Internal Testing**:
   - Add team members as internal testers
   - They can test immediately

3. **External Testing**:
   - Create external testing group
   - Add beta testers (up to 10,000)
   - Submit for Apple review (usually 24-48 hours)

### **Step 5: Beta Tester Invites**

1. **Internal Testers**:
   - Team members with App Store Connect access
   - Can test immediately after build upload

2. **External Testers**:
   - Send email invites with TestFlight link
   - Testers need TestFlight app installed
   - Limited to 10,000 testers

## 🔧 **Required App Store Connect Information**

### **App Information**
- **App Name**: GhostRoll
- **Subtitle**: Martial Arts Training Journal
- **Description**: 
  ```
  GhostRoll is your personal martial arts training companion. Track your sessions, 
  monitor your progress, and stay motivated with a beautiful, intuitive interface 
  designed specifically for martial artists.
  
  Features:
  • Log training sessions with detailed notes
  • Track techniques learned and focus areas
  • Monitor your training streak and progress
  • Calendar integration for class scheduling
  • Customizable belt rank tracking
  • Daily reminders to maintain consistency
  • Beautiful dark theme optimized for training environments
  ```

### **Screenshots Required**
- **iPhone 6.7" Display**: 3-5 screenshots
- **iPhone 6.5" Display**: 3-5 screenshots (optional)
- **iPhone 5.5" Display**: 3-5 screenshots (optional)

### **App Icon** ✅
- **1024x1024 PNG** required ✅
- No transparency
- No rounded corners (Apple adds them)

### **Privacy Policy** ✅
- **URL Required**: `https://ghostroll.app/privacy` (or your actual URL)
- **File Created**: `PRIVACY_POLICY.md` ✅

## 📋 **Pre-Launch Checklist**

### **App Store Connect**
- [ ] App record created
- [ ] Bundle ID matches (`com.nick.ghostroll`)
- [ ] App information filled out
- [ ] Screenshots uploaded
- [ ] App icon uploaded
- [ ] Privacy policy URL provided ✅

### **Build Requirements**
- [ ] App builds successfully in release mode
- [ ] No debug code or test data
- [ ] All features working properly
- [ ] App icon and launch screen configured
- [ ] No placeholder text or images

### **Testing**
- [ ] App tested on multiple devices
- [ ] All core features working
- [ ] No crashes or major bugs
- [ ] Performance acceptable
- [ ] UI/UX polished

## 🚨 **Common Issues & Solutions**

### **Build Errors**
```bash
# If you get signing errors:
flutter clean
cd ios && rm -rf Pods Podfile.lock && cd ..
flutter pub get
flutter build ios --release
```

### **Bundle ID Issues**
- Ensure bundle ID matches in:
  - Xcode project settings
  - App Store Connect
  - Firebase configuration (if using)

### **Upload Failures**
- Check that you're using the correct Apple Developer account
- Ensure app is archived for "Any iOS Device (arm64)"
- Verify all required metadata is provided

## 📞 **Support Resources**

- **Apple Developer Documentation**: [developer.apple.com](https://developer.apple.com)
- **App Store Connect Help**: [help.apple.com/app-store-connect](https://help.apple.com/app-store-connect)
- **TestFlight Guide**: [help.apple.com/testflight](https://help.apple.com/testflight)

## 🎯 **Next Steps After TestFlight**

1. **Gather Feedback**: Use TestFlight feedback or external tools
2. **Fix Issues**: Address bugs and user feedback
3. **Iterate**: Upload new builds as needed
4. **Prepare for App Store**: Once testing is complete, submit for App Store review

---

**Estimated Timeline**: 1-2 days for initial setup, 24-48 hours for external testing approval

## 🚀 **Ready to Deploy!**

Your app is now properly configured for TestFlight deployment. The main steps remaining are:

1. **Create the App Store Connect record**
2. **Build and archive the app**
3. **Upload to TestFlight**
4. **Configure testing groups**

All technical requirements have been met! ✅ 