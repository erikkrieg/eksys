# eksys - System and User Configuration

Nix configurations for my MacOS and NixOS hosts.

## Install MacOS

1. Install Nix package manager: https://nixos.org/download.html#nix-install-macos
2. Clone or download the flake source from GitHub.
3. Run `./bootstrap.sh` to build and apply the system configuration.

The bootstrap command builds a derivation and then activates it with nix-darwin. The bootstrap command likely won't succeed on the first run, but if it fails, there should be instructions for manual remediation. Once those are performed, you can re-run `./bootstrap.sh` (there might be a few cycles of this).

## Update MacOS

Rebuild and apply: `nixswitch`

This is an alias for building and activating the system configuration flake,
which is effectively the same as:

```sh
darwin-rebuild switch --flake .#
```

To get latest packages, go into the flake source directory and run:

```sh
nix flake update
```

_In order to apply the update, use `nixswitch` after._

To update inputs and apply the change run `nixup`.

To update a specific input and rebuild (using `envim` as an example): `just update envim`

Codex and Droid come from the `llm-agents` input. To update that input, commit the
lockfile, and rebuild the current host:

```sh
just update llm-agents
codex --version
```

The pinned revision in `flake.lock` controls these versions; updating `unstable`
alone does not update Codex or Droid.

All hosts use [Numtide's signed binary cache](https://github.com/numtide/llm-agents.nix#binary-cache)
to avoid compiling these tools locally. Shared settings live in
[`hosts/nix-cache-settings.nix`](hosts/nix-cache-settings.nix) and extend each
installation's existing caches and trusted keys. The official Nix cache takes
priority, and signature verification remains required. `llm-agents` keeps its
own nixpkgs pin so its package outputs match the builds in that cache.

NixOS and Nix-managed Darwin hosts apply these settings system-wide. `ek_pro`
uses Determinate Nix's `/etc/nix/nix.custom.conf`; if that file already exists
outside nix-darwin, preserve its settings in the configuration before migrating
it. Standalone Home Manager hosts such as `dev_vm` configure single-user Nix
through `~/.config/nix/nix.conf`. A future Home Manager host using a shared
daemon would also need the cache URL and key configured by its administrator.

To apply cache configuration changes without updating package versions:
run `just rebuild-target HOST` on that host (for example, `just rebuild-target eksys`).
