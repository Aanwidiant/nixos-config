{ config, pkgs, ... }:

let
  reversalBlue = pkgs.reversal-icon-theme.override {
    colorVariants = [ "blue" ];
  };
in
{
  home.packages = with pkgs; [
    reversalBlue
    orchis-theme
    gsettings-desktop-schemas
  ];

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark";
      package = pkgs.orchis-theme;
    };
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Reversal-blue-dark";
      package = reversalBlue;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      icon-theme = "Reversal-blue-dark";
      gtk-theme = "Orchis-Dark";
      cursor-theme = "Bibata-Modern-Ice";
    };
  };

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    XDG_DATA_DIRS = "$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS";
  };
}
