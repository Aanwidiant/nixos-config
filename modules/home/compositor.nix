{ pkgs, ... }:

{
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    hyprpicker
    wlsunset
    swaybg
    quickshell
  ];
}
