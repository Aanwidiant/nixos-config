{ pkgs, ... }:

{
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
          --cmd 'start-hyprland 2>/dev/null'
        '';
        user = "greeter";
      };
    };
  };

  # Hyprland
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

  # Input & gestures
  services.libinput.enable = true;
  services.touchegg.enable = true;
}
