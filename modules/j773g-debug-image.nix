{ config, lib, pkgs, ... }:
let
  rootUUID = config.aurora.imageLayout.rootUUID;
in
{
  # Keep the known-good run-59 boot constraints, but make every boot phase
  # visible and reboot after a stage-1 failure instead of waiting forever.
  boot.consoleLogLevel = lib.mkForce 7;
  boot.plymouth.enable = lib.mkForce false;
  # The archived run-59 config builds the boot-critical storage/filesystem
  # drivers and apple_wdt into the kernel.  Its payload contains no matching
  # loadable .ko files, so stage 1 must not request any modules.
  boot.initrd.availableKernelModules = lib.mkForce [ ];
  boot.initrd.kernelModules = lib.mkForce [ ];
  boot.initrd.systemd.services.aurora-initrd-root.serviceConfig = {
    ExecStartPre = lib.mkForce [ ];
    # This trial root is already plaintext.  The run-59 kernel also has
    # CONFIG_DM_CRYPT unset, so skip the first-boot encryption converter.
    ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
  };
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

  # Validation SSH was injected only into the installed test root and removed
  # after the hardware receipt. No operator key or unlocked root account is
  # part of the reproducible image configuration.
}
