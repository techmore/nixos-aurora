{ buildPkgs, ... }:

let
  version = "7.3.0-m4atlrx+";
  sourceNar = buildPkgs.fetchurl {
    url = "http://10.20.0.117:5000/nar/1b4np921zrqb9kw2pp2ymx6d4qnqqniwnj0v702n7rcvz4i3m1s4.nar?hash=p7ap7hx5llhlc1msjs4ailiy52zqyvqg";
    hash = "sha256-RIc6Ivmb5WMFOBtIy6PF2GLSTK9e3Cv4TAvnH0S6lqw=";
  };
in
buildPkgs.stdenvNoCC.mkDerivation {
  pname = "linux-j773g-run59-binary";
  inherit version;

  outputs = [ "out" "modules" "dev" "config" ];
  nativeBuildInputs = [ buildPkgs.nix ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    nix-store --restore restored < ${sourceNar}

    install -Dm0444 \
      restored/boot/vmlinuz-7.3.0-m4-ctxr-13d3d966 \
      "$out/Image"
    install -Dm0444 \
      restored/t8132-j773g-run59.dtb \
      "$out/dtbs/apple/t8132-j773g.dtb"
    install -m0444 restored/config-7.3.0-m4atlrx+ "$config"

    # Run 59 intentionally has no matching loadable-module tree.  Its boot,
    # NVMe, Ethernet, USB, display and GPU drivers are built in.  Do not put
    # Fedora's incompatible 7.3.0-26 modules under this release name.
    mkdir -p "$modules/lib/modules/${version}" "$dev"
    touch "$modules/lib/modules/${version}/modules.order"
    touch "$modules/lib/modules/${version}/modules.builtin"
    touch "$modules/lib/modules/${version}/modules.builtin.modinfo"

    runHook postInstall
  '';

  passthru = {
    modDirVersion = version;
    kernelFile = "Image";
    dtbs = "dtbs";
    buildDTBs = true;
    isLTS = false;
    isZen = false;
    kernelAtLeast = buildPkgs.lib.versionAtLeast version;
    kernelOlder = buildPkgs.lib.versionOlder version;
    commonMakeFlags = [ ];
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
    description = "Exact J773g run-59 kernel and live DTB, copied without recompilation";
    # This derivation only copies a prebuilt aarch64 Image and DTB.  It must
    # evaluate and run on SER8's x86_64 build platform as well as in the
    # aarch64 target package set.
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = buildPkgs.lib.licenses.gpl2Only;
  };
}
