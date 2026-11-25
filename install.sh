#!/usr/bin/env bash
set -euo pipefail

repository=lennartmoeller/agentic-plugins
marketplace=lennartmoeller
plugin_name=agentic
plugin=$plugin_name@$marketplace
plugin_title="$plugin_name plugin by Lennart Möller"

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
  root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "install.sh needs Git and must run inside the Git repository that should use the plugin."
  has jq || fail "install.sh needs jq: install it (brew install jq, apt install jq, …) and run it again."
  cd "$root"
}

pick_agent() {
  if has claude && has copilot; then
    choose "Claude Code and Copilot CLI are installed. Install the plugin for:" claude copilot
  elif has claude; then
    choose "Claude Code is installed, Copilot CLI is not. Install the plugin for:" claude copilot
  elif has copilot; then
    choose "Copilot CLI is installed, Claude Code is not. Install the plugin for:" copilot claude
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
  local text=$1 found
  shift
  if found=$("$@"); then
    echo "  ✓ $text${found:+ ($found)}"
  else
    echo "  ✗ $text${found:+ ($found)}"
    return 1
  fi
}

check_requirements() {
  local met=true
  echo
  echo "Requirements of the $plugin_name skills:"
  requirement "a POSIX shell" has sh || met=false
  requirement "Git 2.31 or later" version_at_least git 2.31 || met=false
  requirement "GitHub CLI 2.50 or later" version_at_least gh 2.50 || met=false
  requirement "uuidgen or /proc/sys/kernel/random/uuid" uuid_source || met=false
  if ! $met; then
    choose "Some skills will not work until every requirement is met." stop proceed
    [[ $choice != stop ]] || exit 0
  fi
}

settings_patch() {
  jq -n --arg agent "$agent" --arg repository "$repository" --arg marketplace "$marketplace" --arg plugin "$plugin" '{
    extraKnownMarketplaces: {
      ($marketplace): ({source: {source: "github", repo: $repository}} + if $agent == "claude" then {autoUpdate: true} else {} end)
    },
    enabledPlugins: {($plugin): true}
  }'
}

settings_complete() {
  [[ -f $settings ]] && jq -e --argjson patch "$(settings_patch)" '. * $patch == .' "$settings" >/dev/null
}

merge_settings() {
  local merged
  settings_complete && return
  mkdir -p "$(dirname "$settings")"
  merged=$({ cat "$settings" 2>/dev/null || echo '{}'; } | jq --argjson patch "$(settings_patch)" '. * $patch')
  echo "$merged" >"$settings"
}

plugin_installed() {
  case $agent in
    claude) has claude && claude plugin list --json | jq -e --arg plugin "$plugin" --arg root "$root" 'any(.[]; .id == $plugin and .projectPath == $root)' >/dev/null ;;
    copilot) has copilot && copilot plugin list --json | jq -e --arg name "$plugin_name" --arg marketplace "$marketplace" 'any(.[]; .name == $name and .marketplace == $marketplace)' >/dev/null ;;
  esac
}

install() {
  echo
  echo "Setting up the $plugin_title for $(name "$agent")."
  case $agent in
    claude)
      if has claude && ! plugin_installed; then
        claude plugin marketplace add "$repository" --scope project
        claude plugin install "$plugin" --scope project
      fi
      merge_settings
      has claude || echo "Once Claude Code is installed, run in this repository: claude plugin install $plugin --scope project"
      ;;
    copilot)
      merge_settings
      echo "Copilot CLI installs the plugin when you next start it in this repository and trust the folder."
      ;;
  esac
}

update() {
  echo
  echo "The $plugin_title is set up for $(name "$agent"). Checking for a newer version."
  case $agent in
    claude)
      claude plugin marketplace update "$marketplace" >/dev/null
      claude plugin update "$plugin" --scope project
      ;;
    copilot)
      copilot plugin marketplace update "$marketplace" >/dev/null
      copilot plugin update "$plugin"
      ;;
  esac
}

main() {
  local before
  check_own_needs
  pick_agent
  check_requirements
  before=$(cat "$settings" 2>/dev/null || true)
  if settings_complete && plugin_installed; then
    update
  else
    install
  fi
  echo
  # claude plugin install rewrites the settings in its own key order, so an unchanged content gets its original text back.
  if [[ $(jq -S . <<<"$before") == "$(jq -S . "$settings")" ]]; then
    printf '%s\n' "$before" >"$settings"
    echo "Done."
  else
    echo "Done. Commit $settings so everyone working in this repository gets the plugin."
  fi
}

main
