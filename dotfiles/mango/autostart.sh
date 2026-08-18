#!/usr/bin/env bash

dbus-update-activation-environment --systemd \
    WAYLAND_DISPLAY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    DISPLAY \
    NIXOS_OZONE_WL \
    XDG_RUNTIME_DIR

systemctl --user start mango-session.target

# Daemons
qs &
swaybg -i "/home/aanwidiant/.config/theme/current/background" &

# Greeting
my-launch-greeting &

# Clipboard Manager
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# XWayland Support
xwayland-satellite &

# Wait for all background processes to start
wait
