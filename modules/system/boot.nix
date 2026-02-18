{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };

    consoleLogLevel = 3;

    blacklistedKernelModules = [ "raydium_i2c_ts" ];

    kernelParams = [
      "loglevel=3"
      "rd.systemd.show_status=auto"

      "nowatchdog"
      "nmi_watchdog=0"
      "modprobe.blacklist=iTCO_wdt"

      "acpi.debug_level=0"
      "acpi.debug_layer=0"
    ];

    kernelPackages = pkgs.linuxPackages_latest;

    initrd.verbose = false;
    plymouth.enable = false;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
}
