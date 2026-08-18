{ pkgs, ... }:
{
  # Login Manager (Greetd + TUIGreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --cmd mango";
        user = "greeter";
      };
    };
  };

  programs.dconf.enable = true;

  # Desktop Portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk 
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
    };
    wlr.enable = true;
  }; 

  # Input & gestures
  services.libinput.enable = true;
}
