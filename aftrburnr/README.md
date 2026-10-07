# AFTRBURNR

A local-first music player for desktop and mobile (Flutter). Music comes from local files,
Audius and Jamendo through one source-plugin interface. Windows is the first target.

- Design spec: [docs/DESIGN.md](docs/DESIGN.md)
- Architecture: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Step reports: [docs/steps/](docs/steps/)

## Run it on Windows

**Prebuilt:** every push builds the app on a Windows runner. Open the repo's
*Actions* tab → *AFTRBURNR · Windows* → the latest run → download
`aftrburnr-windows-x64`, unzip, run `aftrburnr.exe`. libmpv is bundled.

**From source:**

1. Install Flutter 3.47.6 (stable) and Visual Studio 2022 with the
   *Desktop development with C++* workload.
2. From this folder:

   ```
   flutter pub get
   flutter run -d windows
   ```

   The first build downloads libmpv (~30 MB) from the media_kit project.

Your library, queue and play history live in
`%APPDATA%\dev.aftrburnr\aftrburnr\` (SQLite).

## Develop

```
flutter analyze
flutter test                                   # unit + widget + design guard
AFTRBURNR_MPV_TESTS=1 flutter test test/engine_mpv_test.dart   # real libmpv, needs ffmpeg
AFTRBURNR_SCREENSHOTS=1 flutter test test/screenshots_test.dart --update-goldens
dart run build_runner build                    # after changing drift tables
```
