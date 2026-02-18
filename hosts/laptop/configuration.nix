{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/audio.nix
    ../../modules/system/boot.nix
    ../../modules/system/device.nix
    ../../modules/system/display.nix
    ../../modules/system/fonts.nix
    ../../modules/system/networking.nix
    ../../modules/system/programs.nix
    ../../modules/system/services.nix
    ../../modules/system/security.nix
    ../../modules/system/users.nix
  ];

  system.stateVersion = "25.11";
}
