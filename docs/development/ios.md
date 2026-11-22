# iOS

## Requirements

- Xcode, selected with `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`, and
  CocoaPods (`brew install cocoapods`).
- The Apple Developer team of the owner (team ID `M8NHQ7WV5Z`, set in the Runner target with
  automatic signing). Development installs then stay valid for a year.

## Install on an iPhone

1. Connect the iPhone once by cable, confirm "Trust" and switch on Developer Mode
   (Settings, Privacy & Security). Afterwards Xcode can also reach it over the network.
2. Build and register the device with a provisioning profile that includes it:

   ```sh
   cd app && flutter build ios --release
   cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release \
     -destination id=<udid> -allowProvisioningUpdates -allowProvisioningDeviceRegistration build
   ```

3. Install and start (the iPhone must be unlocked):

   ```sh
   xcrun devicectl device install app --device <udid> \
     ~/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Release-iphoneos/Runner.app
   xcrun devicectl device process launch --device <udid> io.github.mawiak.tivibuddy
   ```

`xcrun devicectl list devices` shows the UDID. The first signing asks the login keychain for
access to the key once per signed framework; "Always allow" (or
`security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k <password>
~/Library/Keychains/login.keychain-db`) stops the prompts.

## Playback

iOS plays with media_kit (libmpv). The Android-only player features (Media3, audio
passthrough, frame rate matching, the native video layer) do not apply.
