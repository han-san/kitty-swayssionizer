#! /bin/sh
#
# Kind of similar to tmux-sessionizer, but without the tmux and persistent
# sessions.
#
# Will open some directory using kitty, or switch to the kitty instance
# with the corresponding mark if there already is one (using sway).
#
# Requires that the environment variables KITTY_SWAYSSIONIZER_SEARCH_DIRS and
# KITTY_SWAYSSIONIZER_0_DIR to KITTY_SWAYSSIONIZER_3_DIR are set in the config
# file at $XDG_CONFIG_HOME/kitty-swayssionizer/config.

set -eu
IFS=$(printf "\n\t")

script_name=$(basename "$0")
termcmd=kitty
menucmd=tofi

show_projects_menu() {
  "$menucmd" --prompt-text="Open project:"
}

exists() {
  command -v "$1" >/dev/null 2>&1
}

log_error() {
  printf "%b\n" "$1" 1>&2

  if exists notify-send; then
    notify-send -u critical "$script_name" "$1"
  fi
}

find_projects() (
  for f in "$@"; do
    find "$f" -mindepth 1 -maxdepth 1 -type d -a ! -path "*/\.*" -prune -print
  done
)

missing_dep=""

if ! exists "$termcmd"; then
  missing_dep="$missing_dep\n$termcmd"
fi

if ! exists "$menucmd"; then
  missing_dep="$missing_dep\n$menucmd"
fi

if ! exists swaymsg; then
  missing_dep="$missing_dep\nswaymsg"
fi

if [ -n "$missing_dep" ]; then
  log_error "The following dependencies are missing:\n$missing_dep"
  exit 1
fi

if [ $# -gt 1 ]; then
  log_error "Usage: $script_name [session_number]"
  exit 1
fi

sessions_file="${XDG_CONFIG_HOME:-$HOME/.config}/$script_name/config"
if ! [ -f "$sessions_file" ]; then
  log_error "FATAL: $script_name config file [$sessions_file] is not a proper file."
  exit 1
fi

# shellcheck source=/dev/null
. "$sessions_file"

# We either select the specified project or let the user fuzzy search all their projects.
dir=""
selection="${1:-}"
case "$selection" in
0)
  dir=$KITTY_SWAYSSIONIZER_0_DIR
  ;;
1)
  dir=$KITTY_SWAYSSIONIZER_1_DIR
  ;;
2)
  dir=$KITTY_SWAYSSIONIZER_2_DIR
  ;;
3)
  dir=$KITTY_SWAYSSIONIZER_3_DIR
  ;;
"")
  newline_search_dirs=$(echo "$KITTY_SWAYSSIONIZER_SEARCH_DIRS" | tr ':' '\n')
  # shellcheck disable=SC2086 # We want to split the variable into arguments.
  dir=$(find_projects $newline_search_dirs | show_projects_menu)

  if [ -z "$dir" ]; then
    exit 0
  fi
  ;;
*)
  log_error "FATAL: Unknown selection [$selection] passed as argument."
  exit 1
  ;;
esac

if [ -z "$dir" ]; then
  log_error "FATAL: No directory selected after case."
  exit 1
fi

if ! swaymsg \[con_mark="$dir"\] focus; then
  "$termcmd" --hold --directory "$dir" swaymsg mark "$dir"
fi
