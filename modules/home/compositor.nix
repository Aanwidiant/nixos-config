{ pkgs, ... }:

{

  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;
  };

  home.packages = with pkgs; [
    swayidle
    hyprlock
    waybar
    mako
    swayosd
    hyprpicker
    wlsunset
    swaybg
    fuzzel
    quickshell
  ];
}
