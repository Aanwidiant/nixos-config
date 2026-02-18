#!/usr/bin/env bash

if pgrep gpu-screen-recorder >/dev/null; then
  echo '{"text":"󰻂","tooltip":"Stop recording","class":"active"}'
else
  echo '{}'
fi
