# Aurora Pantheon for Plasma

An elementary OS look for KDE Plasma 6, selected with
`aurora.kde.theme = "pantheon"` (`modules/kde-theme.nix`). It changes
Plasma's defaults only. Settings a user chooses in System Settings still
take precedence.

| Part | Source |
| --- | --- |
| Global theme `org.aurorasilicon.pantheon.desktop` | This directory: `defaults`, the first-login `layout.js`, `metadata.json` |
| Colour schemes `AuroraPantheon`, `AuroraPantheonDark` | `palette.nix`: elementary's stylesheet palette with the softer Blueberry and Strawberry of ElementaryOS_MSeries |
| Icons `elementary-plasma` | `icons.nix`: elementary/icons, linked unchanged, with a Breeze fallback |
| Cursors `elementary` | nixpkgs `pantheon.elementary-icon-theme` |
| Wallpaper `AuroraPantheon` | Copied from nixpkgs `pantheon.elementary-wallpapers` 8.0.0 |
| Window corners | nixpkgs `kde-rounded-corners` |
| Fonts | nixpkgs `inter` and `roboto-mono` |

Splash, lock screen and logout screens fall back to Breeze, the default
global theme.

## Licenses and attribution

- This directory's files are MIT, like the rest of this repository
  (`LICENSE`).
- elementary icons and cursors: GPL-3.0-or-later,
  https://github.com/elementary/icons. `icons.nix` links them unmodified and
  writes its own `index.theme`, derived from elementary's.
- Wallpaper: "A Large Body of Water Surrounded By Mountains" by Peter Thomas,
  the elementary OS 8 default, from https://github.com/elementary/wallpapers
  (nixpkgs records the collection as public domain). The package's
  `metadata.json` credits the photographer in Plasma's wallpaper picker.
- Inter and Roboto Mono: SIL OFL 1.1, installed from nixpkgs unchanged.
- elementary's colour values are used as named in its stylesheet
  (https://github.com/elementary/stylesheet, GPL-3.0-or-later); no
  stylesheet code is copied.
