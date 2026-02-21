{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    ntfs3g
    btrfs-progs
    efibootmgr
    dosfstools
    mtools
    usbutils
    intel-gpu-tools
    polkit_gnome
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
