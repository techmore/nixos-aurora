{ lib }:
# Plasma colour schemes after elementary OS's stylesheet palette, with the
# softer Blueberry accent and Strawberry error colours of ElementaryOS_MSeries
# (mseries/theme/gtk-4.0.css). Hex values are elementary's named colours:
# SILVER, BLACK, BLUEBERRY, STRAWBERRY, BANANA and LIME.
let
  rgb = hex:
    let channel = i: toString (lib.fromHexString (builtins.substring (1 + 2 * i) 2 hex));
    in "${channel 0},${channel 1},${channel 2}";
  roles = c: background: alternate: {
    BackgroundNormal = rgb background;
    BackgroundAlternate = rgb alternate;
    ForegroundNormal = rgb c.text;
    ForegroundInactive = rgb c.inactiveText;
    ForegroundActive = rgb c.active;
    ForegroundLink = rgb c.link;
    ForegroundVisited = rgb c.visited;
    ForegroundNegative = rgb c.negative;
    ForegroundNeutral = rgb c.neutral;
    ForegroundPositive = rgb c.positive;
    DecorationFocus = rgb c.focus;
    DecorationHover = rgb c.hover;
  };
  scheme = c: {
    "ColorEffects:Disabled" = {
      Color = "56,56,56";
      ColorAmount = 0;
      ColorEffect = 0;
      ContrastAmount = "0.65";
      ContrastEffect = 1;
      IntensityAmount = "0.1";
      IntensityEffect = 2;
    };
    "ColorEffects:Inactive" = {
      ChangeSelectionColor = true;
      Color = "112,111,110";
      ColorAmount = "0.025";
      ColorEffect = 2;
      ContrastAmount = "0.1";
      ContrastEffect = 2;
      Enable = false;
      IntensityAmount = 0;
      IntensityEffect = 0;
    };
    "Colors:Window" = roles c c.window c.windowAlt;
    "Colors:View" = roles c c.view c.viewAlt;
    "Colors:Button" = roles c c.button c.buttonAlt;
    # elementary's header bars continue the window surface; the title bar
    # and toolbars share one slightly darker tone.
    "Colors:Header" = roles c c.header c.window;
    "Colors:Header][Inactive" = roles c c.window c.window;
    "Colors:Selection" = roles c c.selection c.selectionAlt // {
      ForegroundNormal = rgb c.selectionText;
      ForegroundInactive = rgb c.selectionText;
      ForegroundActive = rgb c.selectionText;
    };
    # Tooltips and complementary surfaces (OSDs, the lock screen) are dark in
    # both variants, as elementary's tooltips are.
    "Colors:Tooltip" = roles c c.tooltip c.tooltip // {
      ForegroundNormal = rgb c.tooltipText;
    };
    "Colors:Complementary" = roles c c.tooltip c.tooltip // {
      ForegroundNormal = rgb c.tooltipText;
      ForegroundInactive = rgb "#abacae";
    };
    General = {
      ColorScheme = c.id;
      Name = c.name;
      shadeSortColumn = true;
    };
    KDE.contrast = 4;
    WM = {
      activeBackground = rgb c.header;
      activeBlend = rgb c.header;
      activeForeground = rgb c.text;
      inactiveBackground = rgb c.window;
      inactiveBlend = rgb c.window;
      inactiveForeground = rgb c.inactiveText;
    };
  };
  # Shared by both variants: the MSeries slate-blue accent with dark text.
  accent = {
    selection = "#9dbfe3";
    selectionAlt = "#bcd3ec";
    selectionText = "#1f2f45";
    focus = "#7ba2cc";
    hover = "#9dbfe3";
    tooltip = "#333333";
    tooltipText = "#fafafa";
  };
in {
  light = scheme (accent // {
    id = "AuroraPantheon";
    name = "Aurora Pantheon";
    window = "#fafafa";
    windowAlt = "#f0f0f0";
    view = "#ffffff";
    viewAlt = "#f6f6f6";
    button = "#ffffff";
    buttonAlt = "#f0f0f0";
    header = "#f0f0f0";
    text = "#333333";
    inactiveText = "#7e8087";
    active = "#587fa8";
    link = "#587fa8";
    visited = "#7a5b94";
    negative = "#9a5d65";
    neutral = "#9c6a00";
    positive = "#3a7a2c";
  });
  dark = scheme (accent // {
    id = "AuroraPantheonDark";
    name = "Aurora Pantheon Dark";
    window = "#333333";
    windowAlt = "#2b2b2b";
    view = "#2b2b2b";
    viewAlt = "#303030";
    button = "#404040";
    buttonAlt = "#3a3a3a";
    header = "#2b2b2b";
    text = "#fafafa";
    inactiveText = "#abacae";
    active = "#bcd3ec";
    link = "#bcd3ec";
    visited = "#c6aad0";
    negative = "#f0b5ba";
    neutral = "#e3c98f";
    positive = "#a8caa0";
    tooltip = "#1a1a1a";
  });
}
