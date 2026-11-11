# Series

Requirements: VOD-1, VOD-2 (provider metadata), DATA-1 to DATA-4, RES-1 to RES-3, PLAY-1 to
PLAY-4 (resume), UI-1 to UI-4.

## Behaviour

- **Section layout:** the same as movies (shared `VodBrowser`, see [Movies](movies.md)):
  details of the focused series above one row of posters, categories with left or back,
  "Continue watching", "Favorites" and "All series" per profile, entering from the menu starts
  in the categories. The details come from the provider list, so moving over posters needs no
  requests.
- **Detail page:** cover, title, year, genre, rating and plot; a button that plays or resumes
  where the profile left off ("Play S1 E1", "Resume S2 E4 at 12:30"); favorite. Below it the
  seasons on the left and the episodes of the selected season on the right with image, code,
  title, plot, duration, progress and a check mark when watched. Focusing a season shows its
  episodes; select on an episode plays it, resuming a started one.
- **Next episode:** the last played episode while it is unfinished, else the one after it
  (also across seasons), else the first episode.
- **Player:** the shared VOD player (`vod_player_screen.dart`), see [Movies](movies.md). An
  episode within two minutes of its end counts as watched.

## Data

- `get_series_categories` and `get_series` are loaded like the movie catalog into
  `series_categories` and `series_items` (cache, no sync columns), including plot, genre,
  release date and backdrop of each series.
- `get_series_info` (seasons and episodes) is loaded when the detail page opens and cached
  for ten minutes. Panels send episodes as a map by season or as one list; both are read.
- `series_states` (favorite, last played episode, last watched time) and `episode_states`
  (position, duration, watched) per profile carry the sync columns; series and episodes are
  identified by playlist id and provider ids. "Continue watching" lists series with a last
  watched time, newest first.
- Playback URL: `/series/<user>/<password>/<episode id>.<container_extension>`.

## Not yet implemented

Automatic next episode at the end, marking single episodes or seasons as watched by hand,
search and sorting. See the backlog in `ai/roadmap.md`.
