{ buildPkgs, ... }:

let
  version = "7.3.0-m4atlrx+";
  configValues = {
    CONFIG_BINFMT_ELF = "y";
    CONFIG_FW_LOADER = "y";
    CONFIG_MODULES = "y";
    CONFIG_APPLE_WATCHDOG = "y";
    CONFIG_NVME_APPLE = "y";
    CONFIG_BTRFS_FS = "y";
    CONFIG_EXT4_FS = "y";
    CONFIG_VFAT_FS = "y";
    CONFIG_RUST = "y";
  };
  kernelConfig =
    let
      attrName = attr: "CONFIG_" + attr;
    in
    rec {
      isSet = attr: builtins.hasAttr (attrName attr) configValues;
      getValue = attr: if isSet attr then builtins.getAttr (attrName attr) configValues else null;
      isYes = attr: getValue attr == "y";
      isNo = attr: getValue attr == "n";
      isModule = attr: getValue attr == "m";
      isEnabled = attr: isModule attr || isYes attr;
      isDisabled = attr: !isSet attr || isNo attr;
    }
    // configValues;
  sourceNar = buildPkgs.fetchurl {
    url = "http://10.20.0.117:5000/nar/1b4np921zrqb9kw2pp2ymx6d4qnqqniwnj0v702n7rcvz4i3m1s4.nar?hash=p7ap7hx5llhlc1msjs4ailiy52zqyvqg";
    hash = "sha256-RIc6Ivmb5WMFOBtIy6PF2GLSTK9e3Cv4TAvnH0S6lqw=";
  };
in
buildPkgs.stdenvNoCC.mkDerivation {
  pname = "linux-j773g-run59-binary";
  inherit version;

  outputs = [ "out" "modules" "dev" "configfile" ];
  nativeBuildInputs = [ buildPkgs.python3Minimal buildPkgs.dtc buildPkgs.kmod ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    python ${./restore-nar.py} ${sourceNar} restored

    install -Dm0444 \
      restored/boot/vmlinuz-7.3.0-m4-ctxr-13d3d966 \
      "$out/Image"
    install -Dm0444 \
      restored/t8132-j773g-run59.dtb \
      "$out/dtbs/apple/t8132-j773g.dtb"
    dtc -@ -I dts -O dtb \
      -o ramoops.dtbo ${./j773g-debug-ramoops.dts}
    fdtoverlay \
      -i "$out/dtbs/apple/t8132-j773g.dtb" \
      -o t8132-j773g-debug.dtb ramoops.dtbo
    install -m0444 t8132-j773g-debug.dtb \
      "$out/dtbs/apple/t8132-j773g.dtb"
    printf '%s\n' b3218010d34be05fa0d6ebfb6fd08638ecdb7451 \
      > "$out/aurora-source-commit"
    install -m0444 restored/config-7.3.0-m4atlrx+ "$configfile"

    # The archive contains no matching loadable .ko files.  Record the
    # watchdog built into this exact Image and generate kmod's indexes for its
    # real release.  Never relabel Fedora's incompatible 7.3.0-26 modules.
    mkdir -p "$modules/lib/modules/${version}" "$dev"
    touch "$modules/lib/modules/${version}/modules.order"
    printf '%s\n' kernel/drivers/watchdog/apple_wdt.ko \
      > "$modules/lib/modules/${version}/modules.builtin"
    touch "$modules/lib/modules/${version}/modules.builtin.modinfo"
    depmod -b "$modules" ${version}

    runHook postInstall
  '';

  passthru = {
    modDirVersion = version;
    kernelFile = "Image";
    target = "Image";
    dtbs = "dtbs";
    buildDTBs = true;
    isLTS = false;
    isZen = false;
    kernelAtLeast = buildPkgs.lib.versionAtLeast version;
    kernelOlder = buildPkgs.lib.versionOlder version;
    commonMakeFlags = [ ];
    config = kernelConfig;
    features = {
      ia32Emulation = false;
      efiBootStub = false;
      netfilterRPFilter = true;
      nftables = true;
    };
    auroraSourceCommit = "b3218010d34be05fa0d6ebfb6fd08638ecdb7451";
    auroraDtbAbi = 1;
    auroraCtxrExecmem = true;
  };

  meta = {
    description = "Exact J773g run-59 Image with a test-only ramoops DT reservation";
    # This derivation copies a prebuilt aarch64 Image and only overlays its
    # DTB. It must evaluate and run on SER8's x86_64 build platform as well as
    # in the aarch64 target package set.
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = buildPkgs.lib.licenses.gpl2Only;
  };
}
