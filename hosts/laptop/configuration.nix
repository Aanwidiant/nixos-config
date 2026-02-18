{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/system/boot.nix
    ../modules/system/networking.nix
    ../modules/system/users.nix
    ../modules/system/hardware.nix
    ../modules/system/audio.nix
    ../modules/system/desktop.nix
    ../modules/system/fonts.nix
    ../modules/system/packages.nix
    ../modules/system/services.nix
    ../modules/system/security.nix
    ../modules/system/nix-settings.nix
  ];

  system.stateVersion = "25.11";
}
