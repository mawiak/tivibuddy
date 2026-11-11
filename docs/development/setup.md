# Development environment setup

## Required tools

| Tool                  | Purpose                              | macOS install                              |
|-----------------------|--------------------------------------|--------------------------------------------|
| Flutter (stable)      | App and Dart SDK                     | `brew install --cask flutter`              |
| JDK 21                | Android Gradle builds                | `brew install --cask temurin@21`           |
| Android SDK           | Android and Fire TV builds           | `brew install --cask android-studio`       |
| adb                   | Deploy to devices                    | part of Android SDK platform tools         |
| Docker                | Sync server and PostgreSQL           | Docker Desktop                             |
| Xcode                 | iOS and macOS builds (later)         | Mac App Store                              |

Newer JDKs may not be supported by the Android Gradle Plugin yet. Point Flutter to JDK 21:

```
flutter config --jdk-dir "$(/usr/libexec/java_home -v 21)"
```

## Verify

```
flutter doctor -v
```

Android toolchain, connected device and Flutter itself must be green before working on the app.
