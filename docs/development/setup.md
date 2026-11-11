# Development environment setup

## Required tools

| Tool                  | Purpose                              | macOS install                              |
|-----------------------|--------------------------------------|--------------------------------------------|
| Flutter (stable)      | App and Dart SDK                     | `brew install --cask flutter`              |
| JDK (optional)        | Only if the bundled JDK fails        | `brew install --cask temurin@21`           |
| Android SDK           | Android and Fire TV builds           | `brew install --cask android-studio`       |
| adb                   | Deploy to devices                    | part of Android SDK platform tools         |
| Docker                | Sync server and PostgreSQL           | Docker Desktop                             |
| Xcode                 | iOS and macOS builds (later)         | Mac App Store                              |

Flutter uses the JDK bundled with Android Studio by default, which is the recommended choice.
A separately installed JDK is only needed if Gradle reports an incompatible Java version:

```
flutter config --jdk-dir "$(/usr/libexec/java_home -v 21)"
```

If `flutter doctor` cannot find the Android SDK (for example because `ANDROID_SDK_ROOT` points
to an old location), set it explicitly:

```
flutter config --android-sdk "$HOME/Library/Android/sdk"
```

## Verify

```
flutter doctor -v
```

Android toolchain, connected device and Flutter itself must be green before working on the app.
