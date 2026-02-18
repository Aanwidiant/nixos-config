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
    polkit_gnome
    intel-gpu-tools
  ];

  # Nix-LD (untuk menjalankan dynamic binaries non-NixOS)
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
