#!/usr/bin/env bash

# Shared by Just and bootstrap, not an installed command.
set +x
set -eo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

nix_flags=(--extra-experimental-features "nix-command flakes")

raise_fds() {
  # NixOS/nix#15205: tarball-cache packfiles can exhaust macOS's soft limit.
  # sudo can reset the limit, so repeat this in the root shell below.
  local soft
  soft=$(ulimit -Sn)
  if [ "$soft" = unlimited ] || [ "$soft" -ge 65536 ] 2>/dev/null; then
    return
  fi
  ulimit -Sn 65536 2>/dev/null || ulimit -Sn "$(ulimit -Hn)" 2>/dev/null || true
}

configure_auth() {
  local line entry token
  local entries=()
  # Prefer an explicit GitHub token, and preserve all other Nix settings.
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*(extra-)?access-tokens[[:space:]]*= ]]; then
      line=${line#*=}
      read -r -a entries <<< "${line%%#*}"
      for entry in "${entries[@]}"; do
        case "$entry" in github.com=*) return ;; esac
      done
    fi
  done <<< "${NIX_CONFIG:-}"
  if token=$(gh auth token --hostname github.com 2>/dev/null) && [ -n "$token" ]; then
    [[ "$token" != *[[:space:]]* ]] || return 1
    export NIX_CONFIG="${NIX_CONFIG:+${NIX_CONFIG}
}extra-access-tokens = github.com=$token"
  fi
}

platform_namespace() {
  if [ "$(uname -s)" = Darwin ]; then
    echo darwinConfigurations
  elif test -f /etc/NIXOS; then
    echo nixosConfigurations
  else
    echo homeConfigurations
  fi
}

target_file="${XDG_STATE_HOME:-$HOME/.local/state}/eksys/target"

configured_targets() {
  nix "${nix_flags[@]}" eval --raw ".#$1" \
    --apply 'configs: builtins.concatStringsSep "\n" (builtins.attrNames configs)'
}

# Prints the configuration for this machine: the target remembered from an
# explicit rebuild wins, otherwise one named after the short hostname.
select_target() {
  local targets host saved
  targets=$(configured_targets "$1")
  if [ -r "$target_file" ] && read -r saved < "$target_file"; then
    if printf '%s\n' "$targets" | grep -qxF -- "$saved"; then
      echo "Selected target $saved, remembered in $target_file" >&2
      printf '%s\n' "$saved"
      return
    fi
    echo "Remembered target $saved is no longer a $1 entry; ignoring it." >&2
  fi
  host=$(hostname -s)
  if printf '%s\n' "$targets" | grep -qxF -- "$host"; then
    echo "Selected target $host, matching this hostname" >&2
    printf '%s\n' "$host"
    return
  fi
  echo "No $1 entry matches hostname $host and none is remembered for this machine." >&2
  echo "Run 'just bt TARGET' once (or './bootstrap.sh TARGET') to remember it." >&2
  return 1
}

remember_target() {
  mkdir -p -- "${target_file%/*}"
  printf '%s\n' "$1" > "$target_file"
}

# Sourcing this file loads the helpers above without running a workflow.
[ "${BASH_SOURCE[0]}" = "$0" ] || return 0

raise_fds
configure_auth

if [ "${1:-}" = rebuild ]; then
  namespace=$(platform_namespace)
  explicit=${2:-}
  target=$explicit
  if [ -z "$target" ]; then
    target=$(select_target "$namespace")
  fi
  if [ "$namespace" = homeConfigurations ]; then
    nix "${nix_flags[@]}" run .#home-manager -- \
      switch --flake ".#$target" "${nix_flags[@]}"
  else
    if [ "$namespace" = darwinConfigurations ]; then
      # Also works during bootstrap, before darwin-rebuild is installed.
      system=$(nix "${nix_flags[@]}" build --no-link --print-out-paths \
        ".#darwinConfigurations.$target.system")
      rebuild=("$system/sw/bin/darwin-rebuild")
    else
      rebuild=(nixos-rebuild)
    fi
    sudo --preserve-env=NIX_CONFIG bash -c \
      "$(declare -f raise_fds); raise_fds; exec \"\$@\"" _ \
      "${rebuild[@]}" switch --flake ".#$target"
  fi
  # Recorded only after a successful rebuild, so a bad name is not remembered.
  if [ -n "$explicit" ]; then
    remember_target "$explicit"
  fi
else
  nix "${nix_flags[@]}" "$@"
fi
