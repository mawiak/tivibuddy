# Settings

Requirements: SET-1 to SET-3, I18N-1, I18N-2.

Settings are part of the home screen (last menu entry) and grouped into three sections.

## Profile section (synchronized with the profile)

| Setting     | Values                                       | Default         |
|-------------|----------------------------------------------|-----------------|
| Playlists   | Opens the playlist management                | -               |
| Language    | Device language or any available translation | Device language |
| Reset       | Restores the defaults of the active profile  | -               |

The language list is built from the ARB files (`AppLocalizations.supportedLocales`). Each ARB
file contains a `languageName` key with the name of the language in that language, so a new
translation appears in the list without code changes.

Profile settings are stored as key-value rows (`profile_setting_entries`) with sync columns. A
cleared value keeps a row with `deleted = true` so the change can be synchronized.

## Device section (this installation only)

| Setting         | Values                                        | Default               |
|-----------------|-----------------------------------------------|-----------------------|
| Start profile   | Profile selection or one profile              | Profile selection     |
| Programme guide | Do not load, 1, 2, 3, 5 or 7 days ahead       | 3 days ahead          |
| Profiles        | Opens the profile picker                      | -                     |
| Reset           | Restores the defaults of all device settings  | -                     |

Device settings are stored in `device_setting_entries` and are never synchronized.

## General section

About TiviBuddy: version, license, legal disclaimer and the licenses of the bundled open
source packages.

## Planned

Player, decoder and buffer settings, preferred audio and subtitle languages, category order
and hidden categories, and the sync server configuration are added together with the features
they belong to.
