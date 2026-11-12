{ runCommand, lib, pantheon }:
# elementary's icons and cursors for Plasma. elementary inherits Adwaita,
# which lacks many KDE action and category names; this theme keeps
# elementary's directories and falls back to Breeze before Adwaita. The
# cursors stay in the upstream `elementary` theme.
let
  upstream = pantheon.elementary-icon-theme;
in
runCommand "aurora-elementary-icons-plasma-${upstream.version}" {
  meta = {
    description = "elementary icon theme with Breeze fallback for KDE Plasma";
    homepage = "https://github.com/elementary/icons";
    inherit (upstream.meta) license;
    platforms = lib.platforms.all;
  };
} ''
  src=${upstream}/share/icons/elementary
  theme=$out/share/icons/elementary-plasma
  mkdir -p "$theme"
  for dir in "$src"/*/; do
    name=$(basename "$dir")
    case "$name" in cursors|cursors_scalable) continue ;; esac
    ln -s "$src/$name" "$theme/$name"
  done
  sed -e 's/^Name=elementary$/Name=elementary for Plasma/' \
      -e 's/^Inherits=.*/Inherits=breeze,Adwaita,hicolor/' \
      "$src/index.theme" > "$theme/index.theme"
  grep -qx 'Inherits=breeze,Adwaita,hicolor' "$theme/index.theme"
  grep -qx 'Name=elementary for Plasma' "$theme/index.theme"
  install -Dm644 /dev/stdin $out/share/doc/aurora-elementary-icons-plasma/README <<EOF
  Icons: ${upstream.name} (https://github.com/elementary/icons), GPL-3.0-or-later.
  This package links elementary's icon directories unchanged and replaces only
  index.theme's name and inheritance list.
  EOF
''
