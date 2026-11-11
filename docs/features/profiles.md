# Profiles

Requirements: PROF-1 to PROF-6, SET-1, SYNC-7.

## Behaviour

- **First start:** without any profile the app opens the profile editor. It cannot be cancelled;
  back leaves the app. After saving, the new profile becomes active and home opens.
- **Profile picker:** shown on start when no default profile applies, and from the profile
  entry at the top of the side menu (TV) or the avatar in the app bar (phone). Back returns to
  the active profile, or leaves the app when none is active.
- **Manage mode:** the "Manage profiles" button switches the picker into edit mode. Selecting a
  profile opens its editor.
- **Default profile:** "Start with this profile" in the editor stores the profile as default
  for this device. If another profile is already the default, the user confirms replacing it.
  On start it is activated directly. A default profile with a PIN is not
  bypassed: the picker opens with that profile focused.
- **PIN:** optional, four digits, entered on an on-screen pad (D-pad, touch or number keys).
  Only a salted SHA-256 hash is stored. The PIN is a convenience lock against household
  members, not a security boundary.
- **Avatars:** twelve bundled avatars drawn from icons and colours. On phones, tablets and
  desktops a custom image can be chosen; it is cropped to a 256 px square PNG and stored in the
  database. TV devices do not offer the file option.
- **Delete:** soft delete (`deleted` flag) so the deletion can be synchronized later. Deleting
  the default or active profile clears those references.

## Code

| Layer        | Location                                              |
|--------------|-------------------------------------------------------|
| Domain       | `app/lib/features/profiles/domain/`                   |
| Data         | `app/lib/features/profiles/data/` (drift, PIN hashing, image processing) |
| Application  | `app/lib/features/profiles/application/` (`ProfileActions`, providers)  |
| Presentation | `app/lib/features/profiles/presentation/`             |
| Startup      | `app/lib/features/startup/` and `resolveRedirect` in `app/lib/core/router/app_router.dart` |

The active profile is held in memory (`activeProfileIdProvider`). The default profile is a
device setting (`DeviceSettingsRepository`).
