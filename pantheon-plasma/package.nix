{ stdenvNoCC, lib, writeText, pantheon }:
# An elementary OS look for KDE Plasma: a global theme (look-and-feel) with
# its first-login layout, light and dark colour schemes, elementary's default
# wallpaper as a Plasma wallpaper package, and the system-wide defaults that
# modules/kde-theme.nix installs in /etc/xdg and /etc/plasmalogin.conf.d.
# Plasma applies the global theme named in kdeglobals at every login
# (startplasma writes ~/.config/kdedefaults), so a user's own choices win.
let
  lookAndFeel = "org.aurorasilicon.pantheon.desktop";
  wallpaper = "AuroraPantheon";
  wallpaperFile = "A Large Body of Water Surrounded By Mountains.jpg";
  palette = import ./palette.nix { inherit lib; };
  # KDE nests groups as [file][group] and [group][subgroup]; keep the
  # brackets in section names instead of escaping them.
  ini = lib.generators.toINI { mkSectionName = lib.id; };

  # Qt 6 font descriptions: family, point size, pixel size, style hint,
  # weight, then flags. elementary uses Inter for the interface and Roboto
  # Mono for code; window titles are bold.
  font = family: size: weight: "${family},${toString size},-1,5,${toString weight},0,0,0,0,0,0,0,0,0,0,1";
  fonts = {
    General = {
      font = font "Inter" 10 400;
      menuFont = font "Inter" 10 400;
      toolBarFont = font "Inter" 10 400;
      smallestReadableFont = font "Inter" 8 400;
      fixed = font "Roboto Mono" 10 400;
    };
    WM.activeFont = font "Inter" 10 700;
  };

  # Close on the left and maximize on the right, as Gala draws them;
  # borderless windows with Breeze's centred title.
  decoration = {
    library = "org.kde.breeze";
    theme = "Breeze";
    ButtonsOnLeft = "X";
    ButtonsOnRight = "A";
    BorderSize = "None";
  };

  # Read by Plasma's look-and-feel manager. Fonts are not listed: Plasma 6.8
  # only applies a theme's fonts when kdeglobals [WM] names the interface
  # fonts, so they come from /etc/xdg/kdeglobals instead.
  defaults = {
    "kdeglobals][KDE".widgetStyle = "Breeze";
    "kdeglobals][General".ColorScheme = palette.light.General.ColorScheme;
    "kdeglobals][Icons".Theme = "elementary-plasma";
    "plasmarc][Theme".name = "default";
    Wallpaper.Image = wallpaper;
    "kcminputrc][Mouse".cursorTheme = "elementary";
    "kwinrc][org.kde.kdecoration2" = decoration;
    "ksplashrc][KSplash".Theme = "org.kde.breeze.desktop";
  };

  kdeglobals = lib.recursiveUpdate palette.light (lib.recursiveUpdate fonts {
    KDE = {
      LookAndFeelPackage = lookAndFeel;
      widgetStyle = "Breeze";
    };
    Icons.Theme = "elementary-plasma";
  });

  kwinrc = {
    "org.kde.kdecoration2" = decoration // { BorderSizeAuto = false; };
    # kde-rounded-corners: clip windows to elementary's large radius (the
    # 20 px ElementaryOS_MSeries used for GTK windows and Gala).
    Plugins.kwin4_effect_shapecornersEnabled = true;
    "Round-Corners".Size = 20;
  };

  breezerc = {
    Common.ShadowSize = "ShadowVeryLarge";
    Windeco = {
      TitleAlignment = "AlignCenterFullWidth";
      DrawBorderOnMaximizedWindows = false;
    };
  };

  kcminputrc.Mouse = {
    cursorTheme = "elementary";
    cursorSize = 24;
  };

  metadata = {
    KPackageStructure = "Plasma/LookAndFeel";
    KPlugin = {
      Id = lookAndFeel;
      Name = "Aurora Pantheon";
      Description = "An elementary OS look for Plasma: a top bar, a centred dock, elementary icons, cursors and wallpaper";
      Authors = [ { Name = "Aurora NixOS"; } ];
      License = "MIT";
      Version = "1";
      Website = "https://aurorasilicon.org";
    };
    X-Plasma-APIVersion = "2";
  };

  wallpaperMetadata = {
    KPackageStructure = "Wallpaper/Images";
    KPlugin = {
      Id = wallpaper;
      Name = "A Large Body of Water Surrounded By Mountains";
      Description = "Photo by Peter Thomas, elementary OS 8's default wallpaper (elementary/wallpapers 8.0.0)";
      Authors = [ { Name = "Peter Thomas"; } ];
      License = "As distributed in elementary/wallpapers";
    };
  };

  files = {
    "metadata.json" = writeText "metadata.json" (builtins.toJSON metadata);
    "defaults" = writeText "defaults" (ini defaults);
    "AuroraPantheon.colors" = writeText "AuroraPantheon.colors" (ini palette.light);
    "AuroraPantheonDark.colors" = writeText "AuroraPantheonDark.colors" (ini palette.dark);
    "kdeglobals" = writeText "kdeglobals" (ini kdeglobals);
    "kwinrc" = writeText "kwinrc" (ini kwinrc);
    "breezerc" = writeText "breezerc" (ini breezerc);
    "kcminputrc" = writeText "kcminputrc" (ini kcminputrc);
    "wallpaper.json" = writeText "wallpaper.json" (builtins.toJSON wallpaperMetadata);
  };
  wallpapers = "${pantheon.elementary-wallpapers}/share/backgrounds";
in
stdenvNoCC.mkDerivation {
  pname = "aurora-pantheon-plasma";
  version = "1";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [ ./layout.js ./LICENSE ./README.md ];
  };
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    lnf=$out/share/plasma/look-and-feel/${lookAndFeel}
    install -Dm644 ${files."metadata.json"} $lnf/metadata.json
    install -Dm644 ${files.defaults} $lnf/contents/defaults
    install -Dm644 layout.js $lnf/contents/layouts/org.kde.plasma.desktop-layout.js

    install -Dm644 ${files."AuroraPantheon.colors"} $out/share/color-schemes/AuroraPantheon.colors
    install -Dm644 ${files."AuroraPantheonDark.colors"} $out/share/color-schemes/AuroraPantheonDark.colors

    # A copy, not a link: KPackage rejects files that resolve outside the
    # package directory.
    wp=$out/share/wallpapers/${wallpaper}
    install -Dm644 ${files."wallpaper.json"} $wp/metadata.json
    install -Dm644 "${wallpapers}/${wallpaperFile}" $wp/contents/images/4000x2668.jpg

    xdg=$out/share/aurora-pantheon/xdg
    install -Dm644 ${files.kdeglobals} $xdg/kdeglobals
    install -Dm644 ${files.kwinrc} $xdg/kwinrc
    install -Dm644 ${files.breezerc} $xdg/breezerc
    install -Dm644 ${files.kcminputrc} $xdg/kcminputrc
    # The login screen's wallpaper (Plasma Login Manager reads nested
    # [Greeter][Wallpaper] groups from plasmalogin.conf.d).
    install -d $out/share/aurora-pantheon
    cat > $out/share/aurora-pantheon/plasmalogin.conf <<EOF
    [Greeter][Wallpaper][org.kde.image][General]
    Image=file://$wp/contents/images/4000x2668.jpg
    EOF

    install -Dm644 LICENSE $out/share/licenses/aurora-pantheon-plasma/LICENSE
    install -Dm644 README.md $out/share/doc/aurora-pantheon-plasma/README.md
    runHook postInstall
  '';
  passthru = { inherit lookAndFeel wallpaper; };
  meta = {
    description = "elementary OS look for KDE Plasma: global theme, colour schemes, layout and defaults";
    homepage = "https://aurorasilicon.org";
    # The theme's own files are MIT; the bundled wallpaper keeps the terms
    # under which elementary/wallpapers distributes it (see README.md).
    license = with lib.licenses; [ mit publicDomain ];
    platforms = lib.platforms.all;
  };
}
