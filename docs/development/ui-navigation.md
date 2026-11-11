# UI and remote-control navigation

## Layout classes

`ScreenClass.of(context)` (`app/lib/core/layout/screen_class.dart`) returns `phone`, `tablet`
or `tv`. A 1080p Fire TV reports 960x540 logical pixels, which is the reference size for TV
layouts.

- TV and tablet: left side menu plus content area.
- Phone: content area plus bottom navigation bar.

## Focus components

- `TvFocusable` (`app/lib/shared/widgets/tv_focusable.dart`) is the building block for every
  selectable element. It handles focus, select/enter/game pad A keys, mouse and touch, and
  passes the focus state to its builder. Do not create ad hoc `Focus` wrappers in features.
- `MarqueeText` (`app/lib/shared/widgets/marquee_text.dart`) shows single-line text with an
  ellipsis and scrolls it while `active` is true and the text overflows. Pass the focus state
  of the surrounding row as `active`.
- `TvButton`, `TvListTile`, `TvSwitchTile` (`app/lib/shared/widgets/`) cover buttons and
  settings-like rows.
- `TvTextField` is focused like any other element. Select starts editing and opens the
  keyboard; up/down, submit or leaving the field end editing. A plain `TextField` would trap
  the D-pad.
- `showTvConfirmDialog` and `showTvChoiceDialog` (`tv_dialogs.dart`) are the standard dialogs.
  Confirm dialogs focus cancel first, so destructive actions need a deliberate move.

## Keys

| Remote key        | Flutter input                  | Behaviour                          |
|-------------------|--------------------------------|------------------------------------|
| D-pad             | arrow keys                     | directional focus traversal        |
| Select / OK       | `select`, `enter`, `gameButtonA` | `ActivateIntent` (see `tv_shortcuts.dart`) |
| Back              | system pop route               | content: focus menu; menu: exit    |

The back key does not arrive as a key event. It is handled with `PopScope`.

## Side menu

The side menu is collapsed to icons while the content has focus and expands with labels when
it gets focus, following common IPTV player conventions.

The content area is a `FocusMemoryScopeNode` (`app/lib/shared/widgets/focus_memory_scope.dart`). Right from the menu restores the last focused element
of the content, or its first element after a section change, instead of the geometrically
closest one. While the menu has focus, sections cannot take focus with `autofocus`, so
switching sections keeps the focus in the menu. The element whose `autofocus` was suppressed
becomes the entry point of the next `enter()`, so each section decides with `autofocus` where
focus lands (for example the programme grid of the TV guide instead of its header). The same building block connects the
categories and the channel list of live TV; use it for every list-detail layout.

Back from the content focuses the menu, unless the content handles it first: a section
registers a handler with `ContentBack` (`app/lib/shared/widgets/content_back.dart`), for
example live TV, which opens its categories. Nested `PopScope`s cannot do this, because the
back key is a route pop that every `PopScope` of the route receives.

Directional traversal never leaves a focus scope. Wrap every scope in `LeaveLeft` (same file):
it tries the normal move first and, at the left edge, hands focus to the area on the left
(channel list to categories, any content to the side menu).
