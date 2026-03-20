#!/bin/sh
printf '\033c\033]0;%s\a' Worms Cubed
base_path="$(dirname "$(realpath "$0")")"
"$base_path/worms_cubed.x86_64" "$@"
