{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  # Networking & Time
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  time.timeZone = "Asia/Jakarta";

  # Locale & Input
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ fcitx5-gtk fcitx5-lua ];
  };

  # Users
  users.users.aanwidiant = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" ];
    shell = pkgs.bash;
  };

  # Graphics & Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vulkan-loader
    ];
  };
  hardware.cpu.intel.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  # Environment & Packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git wget vim ntfs3g btrfs-progs
    efibootmgr dosfstools mtools usbutils
  ];

  # Nix-LD
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc zlib fuse3 icu nss expat openssl
  ];

  # Services
  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.printing.enable = true;
  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  virtualisation.docker.enable = true;

  # Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Login Manager (Greetd + TUIGreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --asterisks \
          --cmd 'start-hyprland'
          '';
        user = "greeter";
      };
    };
  };

  # Programs
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.dconf.enable = true;

  # Desktop Portals
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    corefonts # Microsoft fonts
    nerd-fonts.jetbrains-mono
  ];

  # Security & Firewall
  security.sudo.enable = true;
  security.polkit.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      { from = 3000; to = 3005; }
      { from = 5173; to = 5175; }
      { from = 5000; to = 5005; }
      { from = 6000; to = 6005; }
      { from = 8000; to = 9000; }
    ];
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

boot = {
  consoleLogLevel = 0;

  kernelParams = [
    "quiet"
    "loglevel=0"
    "rd.systemd.show_status=no"
    "rd.udev.log_level=0"
    "udev.log_level=0"
  ];
  initrd.verbose = false;
  plymouth.enable = false;
};

  # Nix Settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "25.11";
}
