#!/usr/bin/env bash

# System Environment
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY NIXOS_OZONE_WL &

# Daemons
swayidle &
swaybg -i "/home/aanwidiant/.config/theme/current/background" &

# Bar & Notification
waybar &
mako &

# Greeting
my-launch-greeting &

# Audio & OSD
swayosd-server &

# Clipboard Manager
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# Authentication Agent
/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1 &

# XWayland Support
xwayland-satellite &

# Wait for all background processes to start
wait
