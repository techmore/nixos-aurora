// Aurora Pantheon: Plasma's first-login layout in elementary OS's shape.
// A thin top bar holds the applications menu, a centred clock and the
// status area; a floating dock at the bottom fits its launchers and moves
// out of the way of windows. Plasma runs this only for a user without a
// saved layout, or when the global theme is applied with its layout.

var bar = new Panel;
bar.location = "top";
bar.height = 2 * Math.ceil(gridUnit * 1.6 / 2);
bar.floating = false;
bar.hiding = "none";

// Wingpanel's "Applications" button: a text label without an icon that
// opens the launcher with applications in a grid.
var menu = bar.addWidget("org.kde.plasma.kickoff");
menu.currentConfigGroup = ["General"];
menu.writeConfig("menuLabel", "Applications");
menu.writeConfig("icon", "");
menu.writeConfig("applicationsDisplay", 0);
menu.writeConfig("favoritesDisplay", 0);

bar.addWidget("org.kde.plasma.panelspacer");

var clock = bar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
// 1 is BesideTime: "Wed Nov 12  3:45 PM" on one line.
clock.writeConfig("dateDisplayFormat", 1);
clock.writeConfig("dateFormat", "custom");
clock.writeConfig("customDateFormat", "ddd MMM d");

bar.addWidget("org.kde.plasma.panelspacer");
bar.addWidget("org.kde.plasma.systemtray");

var dock = new Panel;
dock.location = "bottom";
dock.height = 2 * Math.ceil(gridUnit * 3 / 2);
dock.lengthMode = "fit";
dock.alignment = "center";
dock.floating = true;
dock.hiding = "dodgewindows";

var tasks = dock.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
].join(","));
tasks.writeConfig("showOnlyCurrentDesktop", false);

// The global theme's defaults name the wallpaper package; every desktop
// uses the image plugin so that default applies.
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}
