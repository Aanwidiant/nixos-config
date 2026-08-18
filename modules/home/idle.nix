{ pkgs, ... }:

{
  services.swayidle = {
    enable = true;
    # systemdTarget → systemdTargets (sekarang list of string)
    systemdTargets = [ "graphical-session.target" ];
    # Flag -w wajib agar swayidle menunggu hyprlock benar-benar siap sebelum suspend
    extraArgs = [ "-w" ];

    # events sekarang pakai attrset, bukan list
    events = {
      before-sleep = "${pkgs.hyprlock}/bin/hyprlock";
      lock = "pgrep -x hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
    };

    timeouts = [
      # 1. Matikan layar via IPC MangoWM setelah 10 menit
      {
        timeout = 600;
        command = "mmsg dispatch sleep_monitor";
        resumeCommand = "mmsg dispatch wakeup_monitor";
      }
      # 2. Kunci layar setelah 11 menit
      {
        timeout = 660;
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      # 3. Suspend sistem setelah 20 menit
      {
        timeout = 1200;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
