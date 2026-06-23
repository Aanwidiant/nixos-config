{ pkgs, ... }:
{
  # Login Manager (Greetd + TUIGreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Niri
  programs.niri = {
    enable = true;
  };

  programs.dconf.enable = true;

  # Desktop Portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "*";
  };

  # Input & gestures
  services.libinput.enable = true;
}
