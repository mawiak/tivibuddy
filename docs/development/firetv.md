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

## Install a build with the deploy script

```
tool/deploy_firetv.sh <fire-tv-ip>              # release build (default)
tool/deploy_firetv.sh <fire-tv-ip> --profile    # profile build for performance analysis
tool/deploy_firetv.sh <fire-tv-ip> --debug
tool/deploy_firetv.sh <fire-tv-ip> --no-build   # reinstall the last build
```

The script connects through adb, reads the device ABI (`armeabi-v7a` on the Fire TV Stick
Lite, `arm64-v8a` on newer devices), builds split APKs, installs the matching one and starts
the app.

Use release or profile builds to judge performance. Debug builds are much slower.

## Reference device

The Fire TV Stick Lite (armv7, about 1 GB RAM) is the minimum supported device. Performance and
memory must be checked on it before a milestone is marked done.
