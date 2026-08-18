{ pkgs, ... }:

{
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    wayidle
    hyprlock
    hyprpicker
    wlsunset
    swaybg
    quickshell
  ];
}
