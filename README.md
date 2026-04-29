# AgriPulse

Smart Agricultural Market Intelligence app for farmers and traders in Pakistan.

## Highlights

- 20 screen Flutter app with auth, home dashboard, crops, mandi, analytics, tools, news, and profile modules.
- Functional utility flows added:
  - Forgot Password -> OTP Verification -> Reset Password
  - Notifications preferences + test local notification
  - About App screen
  - Weather Advisory screen
  - Market Overview screen

## Screen Count

`lib/screens/**/*.dart` currently contains **20** screens.

## Key Dependencies

- `google_fonts`
- `fl_chart`
- `flutter_native_splash`
- `flutter_launcher_icons` (dev)
- `flutter_local_notifications`

## Run Locally

```powershell
flutter pub get
flutter run
```

## Validation Commands

```powershell
flutter analyze
flutter test
```

## Notes

- Routes are centrally defined in `lib/main.dart`.
- Notification setup is implemented in `lib/services/notification_service.dart` and initialized at startup before `runApp`.
