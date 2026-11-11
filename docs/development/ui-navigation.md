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

## Keys

| Remote key        | Flutter input                  | Behaviour                          |
|-------------------|--------------------------------|------------------------------------|
| D-pad             | arrow keys                     | directional focus traversal        |
| Select / OK       | `select`, `enter`, `gameButtonA` | `ActivateIntent` (see `tv_shortcuts.dart`) |
| Back              | system pop route               | content: focus menu; menu: exit    |

The back key does not arrive as a key event. It is handled with `PopScope`.

## Side menu

The side menu is collapsed to icons while the content has focus and expands with labels when
it gets focus, following common IPTV player conventions. Each section is its own
`FocusTraversalGroup`, so left and right move between menu and content.
