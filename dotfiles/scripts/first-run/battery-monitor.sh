if ls /sys/class/power_supply/BAT* &>/dev/null; then
  powerprofilesctl set balanced || true

  systemctl --user enable --now my-battery-monitor.timer
else
  powerprofilesctl set performance || true
fi
