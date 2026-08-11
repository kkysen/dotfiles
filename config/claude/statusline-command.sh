#!/usr/bin/env bash
# Claude Code statusLine, styled after this repo's `starship.toml`
# (`config/starship.toml` -> `~/.config/starship.toml`, per `scripts/link.sh`).
#
# Segments, in order, mirroring starship's `format`:
#   $time          -> cyan bold,   "HH:MM:SS AM/PM"
#   $directory     -> blue bold,   last 3 path components, $HOME -> ~
#   $git_branch    -> purple,      current branch (via `git`, not the JSON payload)
#   $git_status    -> red,         "*" when the working tree is dirty
#   $memory_usage  -> yellow bold, RAM used, as a percentage
#   (new) context  -> green,       Claude Code context tokens used / window size
#   (new) session  -> cyan,        Claude Code session (5h) rate-limit usage (same % as `/usage`)
#   (new) weekly   -> magenta,     Claude Code weekly (7d) rate-limit usage (same % as `/usage`)
#
# Dropped vs. `starship.toml`, because no equivalent data exists in a
# stateless `statusLine` invocation:
#   $cmd_duration  -> no per-command timing is available here
#   $character     -> no last-exit-code is available here; also, rule 5
#                      (strip trailing $/> prompt chars) argues against it anyway
set -uo pipefail

input="$(cat)"

cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir')"

# --- time: cyan bold ---
time_str="$(date '+%I:%M:%S %p')"

# --- directory: blue bold, last 3 components, $HOME -> ~ ---
dir="$(printf '%s' "$cwd" | sed "s|^$HOME|~|")"
dir="$(printf '%s' "$dir" | awk -F'/' '{
    n = NF
    if (n > 3) {
        print $(n-2) "/" $(n-1) "/" $n
    } else {
        print $0
    }
}')"

# --- git branch: purple ---
branch="$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)"

# --- git status: red, "*" if dirty ---
dirty=""
if [ -n "$branch" ]; then
    status_lines="$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)"
    [ -n "$status_lines" ] && dirty="*"
fi

# --- memory usage: yellow bold, RAM % ---
mem_pct="$(free 2>/dev/null | awk '/^Mem:/ { printf "%.0f", ($3/$2)*100 }')"

# --- Claude Code context: tokens used / context window size ---
fmt_k() {
    # Round to the nearest 1000 and render as "<n>k" (e.g. 187781 -> "188k").
    awk -v n="$1" 'BEGIN { printf "%dk", int((n + 500) / 1000) }'
}

in_tokens_raw="$(printf '%s' "$input" | jq -r '.context_window.total_input_tokens // empty')"
ctx_size_raw="$(printf '%s' "$input" | jq -r '.context_window.context_window_size // empty')"
used_pct_raw="$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')"
in_tokens=""
ctx_size=""
used_pct=""
[ -n "$in_tokens_raw" ] && in_tokens="$(fmt_k "$in_tokens_raw")"
[ -n "$ctx_size_raw" ] && ctx_size="$(fmt_k "$ctx_size_raw")"
[ -n "$used_pct_raw" ] && used_pct="$(printf '%.0f' "$used_pct_raw")"

# --- Claude Code session/weekly rate-limit usage: same percentages `/usage` shows ---
session_pct_raw="$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')"
weekly_pct_raw="$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')"
session_pct=""
weekly_pct=""
[ -n "$session_pct_raw" ] && session_pct="$(printf '%.0f' "$session_pct_raw")"
[ -n "$weekly_pct_raw" ] && weekly_pct="$(printf '%.0f' "$weekly_pct_raw")"

cyan_bold=$'\033[1;36m'
blue_bold=$'\033[1;34m'
purple=$'\033[35m'
red=$'\033[31m'
yellow_bold=$'\033[1;33m'
green=$'\033[32m'
cyan=$'\033[36m'
magenta_bold=$'\033[1;35m'
reset=$'\033[0m'

out="${cyan_bold}${time_str}${reset} "
out="${out}${blue_bold}${dir}${reset}"

if [ -n "$branch" ]; then
    out="${out} ${purple}${branch}${reset}"
fi
if [ -n "$dirty" ]; then
    out="${out} ${red}${dirty}${reset}"
fi
if [ -n "$mem_pct" ]; then
    out="${out} ${yellow_bold}🐏 ${mem_pct}%${reset}"
fi
if [ -n "$ctx_size" ]; then
    out="${out} ${green}context ${in_tokens}/${ctx_size}"
    [ -n "$used_pct" ] && out="${out} (${used_pct}%)"
    out="${out}${reset}"
fi
if [ -n "$session_pct" ]; then
    out="${out} ${cyan}session ${session_pct}%${reset}"
fi
if [ -n "$weekly_pct" ]; then
    out="${out} ${magenta_bold}week ${weekly_pct}%${reset}"
fi

printf '%b' "$out"
