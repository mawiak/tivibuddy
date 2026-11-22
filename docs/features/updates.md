# In-app updates

Android checks the GitHub releases of `mawiak/tivibuddy` and installs new versions from within
the app. Other platforms follow later (see `ai/roadmap.md`): iOS only through TestFlight or the
App Store, macOS and Windows with Sparkle / WinSparkle, Linux as a notice.

## Flow

1. **Check:** `UpdateController` asks the GitHub API for the latest release
   (`GitHubUpdateSource`) and compares its version with the installed one
   (`compareVersions`, semantic versions, pre-releases sort before the release).
   - On start of the home screen when "Check for updates automatically" is on (default) and
     the last check is older than six hours (`updates.autoCheck`, `updates.lastCheck` device
     settings). A new version opens the update dialog.
   - By hand under Settings, General, "Check for updates"; the dialog shows the result.
2. **Download:** the APK for the device's preferred ABI (`tivibuddy-X.Y.Z-<abi>.apk`), the
   universal APK otherwise, into the cache directory (`updates/`), with progress in the dialog.
3. **Install:** without the "install unknown apps" permission the dialog explains it and opens
   the system setting (Fire TV: Settings, My Fire TV, Developer options, Install unknown apps);
   "Install" tries again. The APK goes through a `FileProvider` (`res/xml/update_paths.xml`)
   to the Android package installer (`UpdateInstaller.kt`), where the user confirms.

Updates only install over a lower version code; release builds get increasing version codes
(`tool/build_number.sh`). Every step is logged with `update:`.

## Permissions

`REQUEST_INSTALL_PACKAGES` in the manifest; the user grants "install unknown apps" once.
Unauthenticated GitHub API requests are limited to 60 per hour and address.
