{ username, pkgs, ... }:

{
  services = {
    dbus.enable = true;
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    printing.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    udisks2.enable = true;
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };
  };

  virtualisation.docker.enable = true;

  systemd.services.hyprlock-resume = {
    description = "Lock screen on resume from suspend";
    after = [ "systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service" ];
    wantedBy = [ "systemd-suspend.service" "systemd-hibernate.service" "systemd-hybrid-sleep.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = username;
      Environment = [
        "WAYLAND_DISPLAY=wayland-1"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock'";
    };
  };
}
