{ pkgs, nixpkgs, makeSystem }:
let
  inherit (nixpkgs) lib;
  kde = makeSystem "kde";
  pantheon = kde.extendModules {
    modules = [ { aurora.kde.theme = "pantheon"; } ];
  };
  theme = pantheon.pkgs.aurora-pantheon-plasma;
  icons = pantheon.pkgs.aurora-elementary-icons-plasma;
  etc = config: config.environment.etc;
  installed = config: package: lib.elem package config.environment.systemPackages;
in
assert lib.assertMsg
  (kde.config.aurora.kde.theme == "breeze"
    && !(etc kde.config ? "xdg/kdeglobals")
    && !(etc kde.config ? "xdg/kwinrc")
    && !(installed kde.config kde.pkgs.kde-rounded-corners))
  "The default KDE profile must keep Plasma's own look";
assert lib.assertMsg
  ((etc pantheon.config)."xdg/kdeglobals".source == "${theme}/share/aurora-pantheon/xdg/kdeglobals"
    && (etc pantheon.config) ? "plasmalogin.conf.d/50-aurora-pantheon.conf"
    && installed pantheon.config theme
    && installed pantheon.config icons
    && installed pantheon.config pantheon.pkgs.kde-rounded-corners
    && lib.head pantheon.config.fonts.fontconfig.defaultFonts.sansSerif == "Inter")
  "The Pantheon look must install its theme, icons, corners effect and defaults";
# The names the defaults refer to must exist in the packages that provide them.
pkgs.runCommand "aurora-kde-theme" { } ''
  lnf=${theme}/share/plasma/look-and-feel/${theme.lookAndFeel}
  test -f $lnf/metadata.json
  test -f $lnf/contents/layouts/org.kde.plasma.desktop-layout.js
  grep -qx 'LookAndFeelPackage=${theme.lookAndFeel}' ${theme}/share/aurora-pantheon/xdg/kdeglobals
  grep -qx 'Image=${theme.wallpaper}' $lnf/contents/defaults
  test -f ${theme}/share/wallpapers/${theme.wallpaper}/metadata.json
  test -f ${theme}/share/wallpapers/${theme.wallpaper}/contents/images/4000x2668.jpg
  for scheme in $(sed -n 's/^ColorScheme=//p' $lnf/contents/defaults ${theme}/share/aurora-pantheon/xdg/kdeglobals); do
    test -f ${theme}/share/color-schemes/$scheme.colors
  done
  for name in $(sed -n 's/^Theme=//p' ${theme}/share/aurora-pantheon/xdg/kdeglobals); do
    test -f ${icons}/share/icons/$name/index.theme
  done
  for cursor in $(sed -n 's/^cursorTheme=//p' $lnf/contents/defaults ${theme}/share/aurora-pantheon/xdg/kcminputrc); do
    test -d ${pkgs.pantheon.elementary-icon-theme}/share/icons/$cursor/cursors
  done
  test -d ${icons}/share/icons/elementary-plasma/actions/symbolic/
  image=$(sed -n 's|^Image=file://||p' ${theme}/share/aurora-pantheon/plasmalogin.conf)
  test -f "$image"
  touch $out
''
