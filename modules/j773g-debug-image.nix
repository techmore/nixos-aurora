{ config, lib, ... }:
let
  rootUUID = config.aurora.imageLayout.rootUUID;
in
{
  # Keep the known-good run-59 boot constraints, but make every boot phase
  # visible and reboot after a stage-1 failure instead of waiting forever.
  boot.consoleLogLevel = lib.mkForce 7;
  boot.plymouth.enable = lib.mkForce false;
  boot.kernelParams = lib.mkForce [
    "user4k=on"
    "console=tty0"
    "earlycon"
    "loglevel=7"
    "ignore_loglevel"
    "printk.devkmsg=on"
    "panic=30"
    "nokaslr"
    "pd_ignore_unused"
    "clk_ignore_unused"
    "rd.systemd.show_status=1"
    "rd.systemd.log_target=console"
    "rd.udev.log_level=debug"
    "systemd.show_status=1"
    "nvme_apple.flush_interval=0"
    "firmware_class.path=/run/aurora-firmware/vendorfw"
    "root=UUID=${rootUUID}"
    "rootflags=subvol=root"
    "rw"
    "m4run=j773g-nixos-debug-20261112"
    "ctxr_exec_enforce=0"
    "sn201202x.j773g_no_usb4=1"
    "sn201202x.j773g_no_tbt3=1"
    "pstore.backend=ramoops"
  ];

  services.journald.settings.Journal = {
    Storage = "persistent";
    ForwardToConsole = true;
    TTYPath = "/dev/console";
    MaxLevelConsole = "debug";
  };

  networking.networkmanager.enable = lib.mkForce false;
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-j773g-wired" = {
    matchConfig.Name = "end0";
    networkConfig.DHCP = "yes";
    linkConfig.RequiredForOnline = "routable";
  };

  aurora.openssh.startAtBoot = true;
  services.openssh.openFirewall = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };
  users.users.root = {
    # A valid hash of a discarded random value keeps key-only root SSH usable.
    hashedPassword = "$6$VIS9r/qc44mrsCUU$yAkvquSwh5.9gXZQHi3MAVLQzYqnHWFJ9ht00jSTKv.vJkW.VLuQGUzsgJkn69zqq/cIxdNhZ/Zr8rqICuBEK1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFmj3bexg2JyznrZGGKGrBDNm1OblwAZciPez1Zhmb2"
    ];
  };
}
