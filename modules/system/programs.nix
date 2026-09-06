{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    ntfs3g
    efibootmgr
    dosfstools
    mtools
    usbutils
    intel-gpu-tools
    polkit_gnome
    file-roller
    xwayland-satellite
    unzip
    p7zip 
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

  programs.gpu-screen-recorder.enable = true;

  # Nix-LD
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      expat
      openssl
    ];
  };
}
