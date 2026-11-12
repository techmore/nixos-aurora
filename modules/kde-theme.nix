{ config, lib, pkgs, ... }:
# Plasma's look. "pantheon" installs pantheon-plasma/ and names its global
# theme in /etc/xdg/kdeglobals; startplasma applies that theme's defaults
# for each user at login (~/.config/kdedefaults), and a fresh user's first
# Plasma session uses its top bar and dock layout. The /etc/xdg files also
# reach the Plasma Login greeter and programs started outside Plasma.
let
  cfg = config.aurora.kde;
  theme = pkgs.aurora-pantheon-plasma;
  xdg = "${theme}/share/aurora-pantheon/xdg";
in {
  options.aurora.kde.theme = lib.mkOption {
    type = lib.types.enum [ "breeze" "pantheon" ];
    default = "breeze";
    example = "pantheon";
    description = ''
      Plasma's default look. `breeze` keeps Plasma's own defaults.
      `pantheon` is an elementary OS look: a top bar with an applications
      menu, centred clock and status area; a centred dock that fits its
      launchers; elementary icons, cursors and wallpaper; the Inter font;
      close and maximize buttons on opposite sides; rounded window corners.
      Users can still change each setting, and a user who chose another
      global theme keeps it. Existing users keep their panel layout until
      they apply the theme with its desktop layout in System Settings.
      Requires `aurora.desktop = "kde"`.
    '';
  };
  config = lib.mkIf (cfg.theme == "pantheon") {
    assertions = [ {
      assertion = config.aurora.desktop == "kde";
      message = ''aurora.kde.theme = "pantheon" requires aurora.desktop = "kde".'';
    } ];
    environment.systemPackages = [
      theme
      pkgs.aurora-elementary-icons-plasma
      pkgs.pantheon.elementary-icon-theme
      pkgs.kde-rounded-corners
    ];
    fonts.packages = [ pkgs.inter pkgs.roboto-mono ];
    fonts.fontconfig.defaultFonts = {
      sansSerif = lib.mkBefore [ "Inter" ];
      monospace = lib.mkBefore [ "Roboto Mono" ];
    };
    environment.etc = {
      "xdg/kdeglobals".source = "${xdg}/kdeglobals";
      "xdg/kwinrc".source = "${xdg}/kwinrc";
      "xdg/breezerc".source = "${xdg}/breezerc";
      "xdg/kcminputrc".source = "${xdg}/kcminputrc";
      "plasmalogin.conf.d/50-aurora-pantheon.conf".source =
        "${theme}/share/aurora-pantheon/plasmalogin.conf";
    };
  };
}
