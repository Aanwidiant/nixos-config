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
    gnutar
    xz
    thunar
    xfconf
    thunar-volman
  ];

  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.thunar.plugins = with pkgs; [
    thunar-volman
    thunar-archive-plugin
  ];

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
