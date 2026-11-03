# ميدان / MAYDAN

MAYDAN is an offline-first Flutter application for project, finance, field operations, team, and reporting management.

## Status

- Flutter: 3.47.9
- Dart: 3.13.7
- Android release APK: built locally on 2026-11-03
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- APK size: 53.2 MB
- SHA256: `6c0e238f7281a255edf7df4223f0aae135a6dbace5765e7f8381a50d6717036f`
- Tests: 7 tests passed
- Static analysis: no issues

## Implemented

- SQLite offline storage for projects, transactions, visits, and employees
- Arabic, French, and English UI language selection with RTL/LTR support
- Saved manual language choice, system-language fallback, and Western Arabic numerals
- Dashboard metrics, project creation and progress display
- Income and expense transaction recording
- Field visit recording
- Employee registration with role selection
- Light, dark, and system themes
- Per-company currency selection
- PDF overview report export
- Android back navigation with section history, drawer/dialog handling, and exit confirmation
- Android launcher names: `ميدان` in Arabic and `Maydan` in French/English

## Verification

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
```

## Remaining work

- Full project editing, archive workflows, phases, tasks, and assignees
- Photos and documents for field reports
- Report history with observations, challenges, and change history
- Project assignment and server-independent permission enforcement
- Automated authentication only when a local/cloud identity model is chosen
- Real-device Android verification and GitHub Actions workflow execution
- Browser/Linux desktop tools are outside the Android target and are not required for this APK
