{ buildPkgs, baseKernel, ... }:

buildPkgs.stdenvNoCC.mkDerivation {
  pname = "linux-j773g-run59-debug";
  inherit (baseKernel) version;

  outputs = [ "out" "modules" "dev" "configfile" ];
  nativeBuildInputs = [ buildPkgs.kmod ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out" "$modules" "$dev"
    cp -a ${baseKernel}/. "$out/"
    cp -a ${baseKernel.modules}/. "$modules/"
    cp -a ${baseKernel.dev}/. "$dev/"
    cp ${baseKernel.configfile} "$configfile"

    # The archive contains no loadable .ko files.  Record the watchdog that
    # the exact config builds into the Image, and generate kmod's indexes for
    # the real release rather than relabelling incompatible Fedora modules.
    printf '%s\n' kernel/drivers/watchdog/apple_wdt.ko \
      > "$modules/lib/modules/${baseKernel.modDirVersion}/modules.builtin"
    depmod -b "$modules" ${baseKernel.modDirVersion}

    runHook postInstall
  '';

  passthru = {
    inherit (baseKernel)
      modDirVersion kernelFile target dtbs buildDTBs isLTS isZen
      kernelAtLeast kernelOlder commonMakeFlags config features
      auroraSourceCommit auroraDtbAbi auroraCtxrExecmem;
  };

  meta = baseKernel.meta // {
    description = "Run-59 J773g binary kernel with debug-image built-in module metadata";
    platforms = [ "aarch64-linux" ];
  };
}
