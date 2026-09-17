# eksys - System and User Configuration

Nix configurations for macOS, NixOS, and standalone Linux Home Manager hosts.

## Install MacOS

1. Clone or download the flake source from GitHub.
2. For `ek_pro`, authenticate GitHub CLI with access to the private `lpu-pkgs`
   input (`gh auth login --hostname github.com`). An existing Nix access-token
   configuration also works.
3. Run `./bootstrap.sh ek_pro` (or another target) to install Determinate Nix and
   Homebrew if needed, then build and apply the system configuration. If the
   target is omitted, the short hostname is used.

The bootstrap command builds a derivation and then activates it with nix-darwin. The bootstrap command likely won't succeed on the first run, but if it fails, there should be instructions for manual remediation. Once those are performed, you can re-run `./bootstrap.sh` (there might be a few cycles of this).

## Rebuild and update

The normal workflow, from this checkout, is `git pull` followed by `just b`.
`b` is an alias for `rebuild`. It uses the target remembered for this machine.
Failing that, it picks the configuration named after the short hostname, which
is how the NixOS hosts are named. Either way it reports which target it selected
and where that came from, so an unexpected target is visible before the build.

`just bt ek_pro` (`rebuild-target`) selects a target explicitly and, once the
rebuild succeeds, remembers it in
`${XDG_STATE_HOME:-~/.local/state}/eksys/target`. `./bootstrap.sh ek_pro` does
the same, so a machine is set up once and `just b` works from then on. Run
`just bt` once on a machine that predates this file, or to change which
configuration that machine rebuilds. A remembered name that is no longer
configured is reported and skipped rather than used, and `just b` stops with
instructions instead of guessing.

- `just update INPUT`: update one input, commit the lockfile, then rebuild.
- `just update-nvim`: run `just update envim`, rebuilding once.

Codex and Droid come from the `llm-agents` input. To update that input, commit
the lockfile, and rebuild the current host:

```sh
just update llm-agents
codex --version
```

The pinned revision in `flake.lock` controls these versions; updating `unstable`
alone does not update Codex or Droid.

Just and bootstrap share [`scripts/nix.sh`](scripts/nix.sh) for authentication,
the file-limit workaround, and platform dispatch. It preserves `NIX_CONFIG`,
uses GitHub CLI authentication when needed, and uses the pinned Home Manager
CLI on standalone Linux. Updating all inputs also includes private `lpu-pkgs`.

Run `just test` with Python 3 installed. Real Nix locks and builds disposable
flakes in a temporary directory, while machine identity, GitHub authentication,
and activation are faked. The tests cover target selection and remembering, and
rebuilding exactly once after a successful update. They do not update this
checkout, touch remembered targets, or activate a host. Python is not needed for
normal use.

## Binary caches

All hosts use [Numtide's signed binary cache](https://github.com/numtide/llm-agents.nix#binary-cache)
to avoid compiling these tools locally. Shared settings live in
[`hosts/nix-cache-settings.nix`](hosts/nix-cache-settings.nix) and extend each
installation's existing caches and trusted keys. The official Nix cache takes
priority, and signature verification remains required. `llm-agents` keeps its
own nixpkgs pin so its package outputs match the builds in that cache.

NixOS hosts apply these settings through `nix.settings`. Darwin hosts use
Determinate Nix's `/etc/nix/nix.custom.conf`. Standalone Home Manager hosts such
as `dev_vm` configure single-user Nix
through `~/.config/nix/nix.conf`. A future Home Manager host using a shared
daemon would also need the cache URL and key configured by its administrator.

To apply cache configuration changes without updating package versions:
run `just rebuild-target HOST` on that host (for example, `just rebuild-target eksys`).
