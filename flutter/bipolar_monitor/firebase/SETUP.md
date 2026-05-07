# Firebase Configuration

These files are NOT committed to the repository.

## Android

Place `google-services.json` in:
```
flutter/bipolar_monitor/android/app/google-services.json
```

Download from: Firebase Console → Project Settings → Android app → Download google-services.json

## iOS

Place `GoogleService-Info.plist` in:
```
flutter/bipolar_monitor/ios/Runner/GoogleService-Info.plist
```

Download from: Firebase Console → Project Settings → iOS app → Download GoogleService-Info.plist

## Required Firebase services

- **Firebase Cloud Messaging** (FCM) — push notifications for analysis results
- **Firebase Analytics** (optional) — only if you want usage analytics

## .gitignore

The following are already in `.gitignore`:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```
