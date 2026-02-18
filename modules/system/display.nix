{ pkgs, ... }:

{
  # Login Manager (Greetd + TUIGreet)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.bash}/bin/bash -c "sleep 1; exec ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --asterisks \
            --cmd start-hyprland"
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
