# iOS Build Issues - Known Problems

## Swift Module Dependency Errors

### Issue
Swift compiler cannot find Objective-C modules:
- `GoogleUtilities`
- `GTMSessionFetcher` 
- `AppAuth`
- `FBLPromises`

### Status
- ✅ Privacy manifest errors: FIXED
- ✅ Podfile configuration: Multiple approaches tried
- ❌ Swift module resolution: PERSISTS

### What We've Tried
1. Updated Firebase dependencies
2. Static frameworks (`use_frameworks! :linkage => :static`)
3. Dynamic frameworks (`use_frameworks!`)
4. Modular headers (`use_modular_headers!`)
5. Explicit module map paths
6. Build order dependencies
7. Manual Xcode configuration (DEFINES_MODULE, CLANG_ENABLE_MODULES)

### Possible Solutions (Not Yet Tried)
1. **Check Firebase/CocoaPods compatibility** - May need specific version combinations
2. **Remove Firebase temporarily** - Test if build succeeds without Firebase
3. **Use Firebase via different method** - e.g., REST API instead of SDK
4. **Wait for Firebase/CocoaPods updates** - May be fixed in future versions
5. **Manual bridging** - Create custom bridging headers

### Current Workaround
Build works for simulator (after creating privacy manifests).
Device builds fail on Swift module dependencies.

### Next Steps
- Document as known limitation
- Continue development on simulator/web
- Revisit when Firebase/CocoaPods versions update
- Or investigate Firebase GitHub issues for known compatibility problems
