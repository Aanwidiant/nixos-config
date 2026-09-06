{ ... }:

{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "wlroots";
  };
}
