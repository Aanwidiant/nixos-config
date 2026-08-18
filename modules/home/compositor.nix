{ pkgs, ... }:

{
  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    # swayidle
    wayidle
    hyprlock
    hyprpicker
    wlsunset
    swaybg
    quickshell
  ];
}
