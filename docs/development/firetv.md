# Testing on Fire TV

## Enable developer mode on the device

1. Settings > My Fire TV > About: select the device name seven times to unlock developer
   options.
2. Settings > My Fire TV > Developer options: enable ADB debugging and apps from unknown
   sources.
3. Settings > My Fire TV > About > Network: note the IP address.

## Connect

```
adb connect <fire-tv-ip>:5555
adb devices
```

Accept the debugging prompt on the TV the first time.

## Run with hot reload

```
cd app
flutter run -d <fire-tv-ip>:5555
```

## Install a release build

A deploy script will be added in milestone 1 (`tool/deploy_firetv.sh <fire-tv-ip>`). It builds
split APKs for armeabi-v7a and arm64-v8a and installs the matching one.

## Reference device

The Fire TV Stick Lite (armv7, about 1 GB RAM) is the minimum supported device. Performance and
memory must be checked on it before a milestone is marked done.
