# How to Get Your Firebase Web Configuration

Since you already have iOS and Android set up, you just need to add a **Web App** to your existing Firebase project to get the keys for the browser version.

1.  **Go to Firebase Console**: [https://console.firebase.google.com/](https://console.firebase.google.com/)
2.  **Select your project**: Click on "GhostRoll" (or whatever you named it).
3.  **Add Web App**:
    *   Look for the **Project Overview** page (the main dashboard).
    *   You should see icons for iOS (+) and Android (+). Look for the **Web icon** `</>` (it looks like code brackets).
    *   Click the `</>` icon to add a new Web app.
4.  **Register App**:
    *   **App nickname**: Enter "GhostRoll Web".
    *   (Optional) "Also set up Firebase Hosting": You can leave this unchecked for now.
    *   Click **Register app**.
5.  **Copy Config**:
    *   You will see a code block with `const firebaseConfig = { ... };`.
    *   **Copy the values** inside that block. I need:
        *   `apiKey`
        *   `appId`
        *   `messagingSenderId`
        *   `measurementId` (if present)

**Once you have these, please paste them here, and I will update your code.**
