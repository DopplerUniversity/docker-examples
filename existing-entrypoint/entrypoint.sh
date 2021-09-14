#! /usr/bin/env sh

echo "[info]: Starting application with command - \"${@}\""
exec doppler run -- "$@"
