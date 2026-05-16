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

## Environment Setup

Create a local `.env` file at the project root (not committed):

```dotenv
WEATHER_API_KEY=your_weatherapi_key
GROQ_API_KEY=your_groq_api_key
```

## Services

- `lib/services/weather_service.dart` loads live forecasts from WeatherAPI.
- `lib/services/groq_service.dart` provides AI recommendations via Groq.

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
