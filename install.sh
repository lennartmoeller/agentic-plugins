#!/usr/bin/env bash
set -euo pipefail

repository=lennartmoeller/agentic-plugins
marketplace=lennartmoeller
plugins="ethos empty-house-refactoring list-github-findings"

fail() {
  echo "$*" >&2
  exit 1
}

has() {
  command -v "$1" >/dev/null
}

name() {
  case $1 in
    claude) echo "Claude Code" ;;
    copilot) echo "Copilot CLI" ;;
    stop) echo "Stop" ;;
    proceed) echo "Proceed anyway" ;;
    yes) echo "Yes" ;;
    no) echo "No" ;;
  esac
}

choose() {
  local question=$1 answer i
  shift
  echo
  echo "$question"
  for ((i = 1; i <= $#; i++)); do
    echo "  $i) $(name "${!i}")"
  done
  while true; do
    read -r -p "> " answer </dev/tty
    if [[ $answer =~ ^[0-9]+$ ]] && ((answer >= 1 && answer <= $#)); then
      choice=${!answer}
      return
    fi
  done
}

check_own_needs() {
  { true </dev/tty; } 2>/dev/null || fail "install.sh asks questions, so run it in a terminal."
  root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "install.sh needs Git and must run inside the Git repository that should use the plugins."
  has jq || fail "install.sh needs jq: install it (brew install jq, apt install jq, …) and run it again."
  cd "$root"
}

pick_agent() {
  if has claude && has copilot; then
    choose "Claude Code and Copilot CLI are installed. Set up the plugins for:" claude copilot
  elif has claude; then
    choose "Claude Code is installed, Copilot CLI is not. Set up the plugins for:" claude copilot
  elif has copilot; then
    choose "Copilot CLI is installed, Claude Code is not. Set up the plugins for:" copilot claude
  else
    choose "Neither Claude Code nor Copilot CLI is installed. Proceed anyway with:" stop claude copilot
  fi
  [[ $choice != stop ]] || exit 0
  agent=$choice
  case $agent in
    claude) settings=.claude/settings.json ;;
    copilot) settings=.github/copilot/settings.json ;;
  esac
}

settings_patch() {
  jq -n --arg agent "$agent" --arg repository "$repository" --arg marketplace "$marketplace" --arg plugins "$1" '{
    extraKnownMarketplaces: {
      ($marketplace): ({source: {source: "github", repo: $repository}} + if $agent == "claude" then {autoUpdate: true} else {} end)
    },
    enabledPlugins: ($plugins | split(" ") | map(select(. != "") | {key: "\(.)@\($marketplace)", value: true}) | from_entries)
  }'
}

settings_complete() {
  [[ -f $settings ]] && jq -e --argjson patch "$(settings_patch "$1")" '. * $patch == .' "$settings" >/dev/null
}

plugin_installed() {
  case $agent in
    claude) has claude && claude plugin list --json | jq -e --arg plugin "$1@$marketplace" --arg root "$root" 'any(.[]; .id == $plugin and .projectPath == $root)' >/dev/null ;;
    copilot) has copilot && copilot plugin list --json | jq -e --arg name "$1" --arg marketplace "$marketplace" 'any(.[]; .name == $name and .marketplace == $marketplace)' >/dev/null ;;
  esac
}

pick_plugins() {
  local plugin
  installed="" chosen=""
  for plugin in $plugins; do
    if settings_complete "$plugin" && plugin_installed "$plugin"; then
      installed+=" $plugin"
    else
      choose "Set up the $plugin plugin?" yes no
      [[ $choice == no ]] || chosen+=" $plugin"
    fi
  done
  if [[ -z $installed$chosen ]]; then
    echo
    echo "Nothing to set up."
    exit 0
  fi
}

version_at_least() {
  local found
  found=$("$1" --version 2>/dev/null | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n 1) || return 1
  echo "$found"
  [[ $(printf '%s\n' "$2" "$found" | sort -t . -k 1,1n -k 2,2n -k 3,3n | head -n 1) == "$2" ]]
}

uuid_source() {
  has uuidgen || [[ -r /proc/sys/kernel/random/uuid ]]
}

requirement() {
  local text=$1 needed_by=$2 plugin found
  shift 2
  for plugin in $needed_by; do
    [[ " $installed $chosen " == *" $plugin "* ]] || continue
    if found=$("$@"); then
      rows+=("  ✓ $text${found:+ ($found)}")
    else
      rows+=("  ✗ $text${found:+ ($found)}")
      met=false
    fi
    return
  done
}

check_requirements() {
  local met=true rows=()
  requirement "a POSIX shell" "ethos list-github-findings" has sh
  requirement "Git 2.31 or later" ethos version_at_least git 2.31
  requirement "GitHub CLI 2.50 or later" "ethos list-github-findings" version_at_least gh 2.50
  requirement "uuidgen or /proc/sys/kernel/random/uuid" ethos uuid_source
  ((${#rows[@]})) || return 0
  echo
  echo "Requirements of the plugins:"
  printf '%s\n' "${rows[@]}"
  if ! $met; then
    choose "Some skills will not work until every requirement is met." stop proceed
    [[ $choice != stop ]] || exit 0
  fi
}

merge_settings() {
  local merged
  settings_complete "$installed $chosen" && return
  mkdir -p "$(dirname "$settings")"
  merged=$({ cat "$settings" 2>/dev/null || echo '{}'; } | jq --argjson patch "$(settings_patch "$installed $chosen")" '. * $patch')
  echo "$merged" >"$settings"
}

set_up() {
  local plugin
  echo
  [[ -z $installed ]] || echo "Set up for $(name "$agent") already, checking for a newer version:$installed"
  [[ -z $chosen ]] || echo "Setting up for $(name "$agent"):$chosen"
  case $agent in
    claude)
      if has claude; then
        [[ -z $chosen ]] || claude plugin marketplace add "$repository" --scope project
        claude plugin marketplace update "$marketplace" >/dev/null
        for plugin in $chosen; do
          claude plugin install "$plugin@$marketplace" --scope project
        done
        for plugin in $installed; do
          claude plugin update "$plugin@$marketplace" --scope project
        done
      fi
      merge_settings
      for plugin in $chosen; do
        has claude || echo "Once Claude Code is installed, run in this repository: claude plugin install $plugin@$marketplace --scope project"
      done
      ;;
    copilot)
      merge_settings
      if [[ -n $installed ]]; then
        copilot plugin marketplace update "$marketplace" >/dev/null
        for plugin in $installed; do
          copilot plugin update "$plugin@$marketplace"
        done
      fi
      [[ -z $chosen ]] || echo "Copilot CLI installs the new plugins when you next start it in this repository and trust the folder."
      ;;
  esac
}

main() {
  local before
  check_own_needs
  pick_agent
  pick_plugins
  check_requirements
  before=$(cat "$settings" 2>/dev/null || true)
  set_up
  echo
  # claude plugin install rewrites the settings in its own key order, so an unchanged content gets its original text back.
  if [[ $(jq -S . <<<"$before") == "$(jq -S . "$settings")" ]]; then
    printf '%s\n' "$before" >"$settings"
    echo "Done."
  else
    echo "Done. Commit $settings so everyone working in this repository gets the plugins."
  fi
}

main
