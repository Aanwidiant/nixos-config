#!/usr/bin/env bash

if pgrep -x "wf-recorder" >/dev/null; then
  echo '{"text":"󰻂","tooltip":"Recording in progress... Click to stop.","class":"active"}'
else
  echo '{}'
fi
