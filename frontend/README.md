# Frontend — Sleep Quality Analyzer

## Run web
```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

## Run Android Emulator
```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8010
```

## Build Windows
```powershell
flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:8010
```

## Release Candidate UI screens
- Log
- History
- Insights
- Charts
- Predict
- What-if
- System Status
- About
