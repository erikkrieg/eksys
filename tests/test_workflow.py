"""Behavior tests for the rebuild workflow.

Real Nix evaluates, locks, and builds disposable flakes in a temporary
directory. Only machine identity, GitHub authentication, and root are faked.
The stand-in for sudo runs the privileged step as this user, but like root it
cannot fetch the user's private flake inputs, and it records changes to the
system profile instead of making them. The stand-in system's darwin-rebuild
records which system it activates, so the tests observe results rather than
the commands used to produce them.
"""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
NIX = shutil.which("nix")
JUST = shutil.which("just")
GIT = shutil.which("git")

HOSTS = """
{
  outputs = { self }: {
    darwinConfigurations = { ek_pro = {}; eksys = {}; };
    homeConfigurations.dev_vm = {};
    nixosConfigurations = { june = {}; noosh = {}; };
  };
}
"""

# A buildable stand-in for a host system. It builds offline by unpacking an
# archive from an input, so a rebuild reaches activation without any real host
# configuration.
SYSTEM = """
{
  inputs.dependency.url = "path:%s";
  inputs.extra.url = "path:%s";
  outputs = { self, dependency, ... }:
    let
      system = name: derivation {
        inherit name;
        system = "builtin";
        builder = "builtin:fetchurl";
        url = "file://${dependency.archive}";
        unpack = true;
        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = builtins.hashFile "sha256" dependency.archive;
      };
    in {
      darwinConfigurations = {
        ek_pro.system = system "ek_pro";
        spare.system = system "spare";
      };
    };
}
"""

# The stand-in system's darwin-rebuild, which records the system it activates.
# Like the real one, switch first builds FLAKE#NAME again and sets the system
# profile, while activate uses the system it belongs to.
DARWIN_REBUILD = r"""#!/bin/bash
system=${0%/sw/bin/darwin-rebuild}
if [ "$1" = switch ]; then
  system=$(nix build --no-link --print-out-paths \
    "${3%#*}#darwinConfigurations.${3#*#}.system") || exit
  nix-env -p /nix/var/nix/profiles/system --set "$system" || exit
fi
echo "$system" >> "$FAKE_ACTIVATIONS"
"""


class Workspace(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.repo = Path(temp.name).resolve()
        (self.repo / "scripts").mkdir()
        for name in ("Justfile", "scripts/nix.sh"):
            shutil.copy2(ROOT / name, self.repo / name)
        self.activations = self.repo / "activations"
        self.profiles = self.repo / "profiles"
        self.state = self.repo / "state"
        fakes = self.repo / "fakes.sh"
        fakes.write_text(f"""
hostname() {{ echo "${{FAKE_HOST:-unmatched-hostname}}"; }}
uname() {{ echo Darwin; }}
gh() {{ echo synthetic-token; }}
nix() {{
  if [ -n "${{FAKE_ROOT:-}}" ]; then
    echo "error: root cannot fetch the user's private flake inputs" >&2
    return 1
  fi
  "{NIX}" --offline "$@"
}}
sudo() {{
  while [ "${{1#-}}" != "$1" ]; do shift; done
  FAKE_ROOT=1 "$@"
}}
nix-env() {{
  [ "$1" = -p ] && [ "$3" = --set ] && echo "$2 $4" >> "{self.profiles}"
}}
""")
        self.env = {
            "PATH": os.pathsep.join((str(Path(JUST).parent), "/usr/bin", "/bin")),
            "HOME": str(self.repo),
            "BASH_ENV": str(fakes),
            "XDG_STATE_HOME": str(self.state),
            "FAKE_ACTIVATIONS": str(self.activations),
            "NIX_CONF_DIR": str(self.repo / "no-system-settings"),
            "NIX_USER_CONF_FILES": "/dev/null",
        }

    def remembered(self):
        target = self.state / "eksys" / "target"
        return target.read_text().strip() if target.exists() else None

    def run_command(self, *args, **env):
        return subprocess.run(args, cwd=self.repo, env=dict(self.env, **env),
                              capture_output=True, text=True)

    def activated(self):
        """The systems activated so far, in order."""
        return self.activations.read_text().split() if self.activations.exists() else []

    def activation_count(self):
        return len(self.activated())

    def profile_changes(self):
        """The (profile, system) pairs root has set, in order."""
        if not self.profiles.exists():
            return []
        return [tuple(line.split()) for line in self.profiles.read_text().splitlines()]


class TargetSelectionTests(Workspace):
    def setUp(self):
        super().setUp()
        (self.repo / "flake.nix").write_text(HOSTS)

    def select(self, namespace, host="unmatched-hostname"):
        return self.run_command("/bin/bash", "-c",
                                f"source ./scripts/nix.sh; select_target {namespace}",
                                FAKE_HOST=host)

    def remember(self, target):
        (self.state / "eksys").mkdir(parents=True, exist_ok=True)
        (self.state / "eksys" / "target").write_text(target + "\n")

    def test_selects_the_configuration_named_after_the_hostname(self):
        for namespace, host in (("darwinConfigurations", "eksys"),
                                ("nixosConfigurations", "june")):
            with self.subTest(host=host):
                result = self.select(namespace, host=host)
                self.assertEqual(result.stdout.strip(), host, result.stderr)

    def test_the_remembered_target_outranks_the_hostname(self):
        self.remember("ek_pro")
        for host in ("eksys", "unmatched-hostname"):
            with self.subTest(host=host):
                result = self.select("darwinConfigurations", host=host)
                self.assertEqual(result.stdout.strip(), "ek_pro", result.stderr)

    def test_selects_nothing_without_a_hostname_match_or_a_remembered_target(self):
        result = self.select("darwinConfigurations")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "")

    def test_a_remembered_target_that_no_longer_exists_falls_back_to_the_hostname(self):
        self.remember("retired_host")
        result = self.select("darwinConfigurations", host="eksys")
        self.assertEqual(result.stdout.strip(), "eksys", result.stderr)

    def test_a_remembered_target_that_no_longer_exists_is_never_substituted(self):
        self.remember("retired_host")
        result = self.select("darwinConfigurations")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout.strip(), "")


class RebuildTests(Workspace):
    def setUp(self):
        super().setUp()
        self.env["FAKE_HOST"] = "ek_pro"
        tree = self.repo / "system"
        (tree / "sw" / "bin").mkdir(parents=True)
        rebuild = tree / "sw" / "bin" / "darwin-rebuild"
        rebuild.write_text(DARWIN_REBUILD)
        rebuild.chmod(0o755)
        packed = subprocess.run((NIX, "--extra-experimental-features", "nix-command",
                                 "nar", "pack", str(tree)), env=self.env, capture_output=True)
        self.assertEqual(packed.returncode, 0, packed.stderr)
        self.dependencies = {}
        for name in ("dependency", "extra"):
            path = self.repo / name
            path.mkdir()
            (path / "system.nar").write_bytes(packed.stdout)
            (path / "flake.nix").write_text(
                "{ outputs = { self }: { archive = ./system.nar; }; }\n")
            self.dependencies[name] = path
        self.lock = self.repo / "flake.lock"
        (self.repo / "flake.nix").write_text(
            SYSTEM % (self.dependencies["dependency"], self.dependencies["extra"]))
        result = self.run_command("/bin/bash", "scripts/nix.sh", "flake", "lock")
        self.assertEqual(result.returncode, 0, result.stderr)

    def system(self, name):
        """The system that the flake defines for a target."""
        result = self.run_command("/bin/bash", "scripts/nix.sh", "eval", "--raw",
                                  f".#darwinConfigurations.{name}.system.outPath")
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_rebuild_activates_the_selected_and_requested_targets(self):
        result = self.run_command(JUST, "b")
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.run_command(JUST, "bt", "spare")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activated(), [self.system("ek_pro"), self.system("spare")])

    def test_root_records_and_activates_the_system_this_user_built(self):
        # Root cannot fetch the user's private inputs, so it must not evaluate
        # the flake again; only this user's build can reach them.
        result = self.run_command(JUST, "b")
        self.assertEqual(result.returncode, 0, result.stderr)
        system = self.system("ek_pro")
        self.assertEqual(self.profile_changes(), [("/nix/var/nix/profiles/system", system)])
        self.assertEqual(self.activated(), [system])

    def test_an_explicit_target_is_remembered_for_later_rebuilds(self):
        # The hostname matches ek_pro here, so the remembered value must win.
        result = self.run_command(JUST, "bt", "spare")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.remembered(), "spare")
        result = self.run_command("/bin/bash", "-c",
                                  "source ./scripts/nix.sh; select_target darwinConfigurations")
        self.assertEqual(result.stdout.strip(), "spare", result.stderr)
        result = self.run_command(JUST, "b")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activated(), [self.system("spare")] * 2)

    def test_a_failed_rebuild_is_not_remembered_recorded_or_activated(self):
        result = self.run_command(JUST, "bt", "no_such_host")
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(self.remembered())
        self.assertEqual(self.profile_changes(), [])
        self.assertEqual(self.activated(), [])

    def test_a_failed_update_leaves_the_lockfile_and_system_alone(self):
        locked = self.lock.read_bytes()
        # "extra" is unreachable but unused, so only updating it can fail.
        shutil.rmtree(self.dependencies["extra"])
        result = self.run_command(JUST, "update", "extra")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.activation_count(), 0)
        self.assertEqual(self.lock.read_bytes(), locked)
        result = self.run_command(JUST, "b")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activation_count(), 1, "the skipped rebuild would have worked")

    def test_a_successful_update_activates_once(self):
        result = self.run_command(JUST, "update", "dependency")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activation_count(), 1)

    def test_existing_nix_settings_and_any_configured_token_survive(self):
        for github, expected in (
            ("", "synthetic-token"),
            (" github.com=explicit-token", "explicit-token"),
            ("\nextra-access-tokens = github.com=extra-token", "extra-token"),
        ):
            with self.subTest(github=github or "supplied by gh"):
                config = "max-jobs = 3\naccess-tokens = gitlab.example=other-token" + github
                result = self.run_command("/bin/bash", "scripts/nix.sh", "config", "show",
                                          "--json", NIX_CONFIG=config)
                self.assertEqual(result.returncode, 0, result.stderr)
                settings = json.loads(result.stdout)
                self.assertEqual(settings["max-jobs"]["value"], 3)
                self.assertEqual(settings["access-tokens"]["value"],
                                 {"gitlab.example": "other-token", "github.com": expected})


class FetchTests(Workspace):
    """A local bare repository stands in for GitHub."""

    def setUp(self):
        super().setUp()
        self.env["PATH"] = os.pathsep.join((str(Path(GIT).parent), self.env["PATH"]))
        self.remote = self.repo / "remote.git"
        self.publisher = self.repo / "publisher"
        self.checkout = self.repo / "checkout"
        self.git(self.repo, "init", "-q", "--bare", str(self.remote))
        self.git(self.repo, "clone", "-q", str(self.remote), str(self.publisher))
        self.publish("main")
        self.publish("26.05")
        self.set_default("26.05")
        self.git(self.repo, "clone", "-q", str(self.remote), str(self.checkout))

    def git(self, cwd, *args):
        # Unlike the commands under test, fixtures keep the caller's environment,
        # so their commits use the Git identity already configured there.
        result = subprocess.run((GIT, *args), cwd=cwd, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def publish(self, branch):
        """Push a new commit to the remote branch and return its hash."""
        self.git(self.publisher, "commit", "-q", "--allow-empty", "--no-gpg-sign", "-m", branch)
        self.git(self.publisher, "push", "-q", "origin", f"HEAD:refs/heads/{branch}")
        return self.git(self.publisher, "rev-parse", "HEAD")

    def set_default(self, branch):
        self.git(self.remote, "symbolic-ref", "HEAD", f"refs/heads/{branch}")

    def fetch(self):
        result = self.run_command(JUST, "--justfile", str(self.repo / "Justfile"),
                                  "--working-directory", str(self.checkout), "fetch")
        self.assertEqual(result.returncode, 0, result.stderr)
        return (self.git(self.checkout, "branch", "--show-current"),
                self.git(self.checkout, "rev-parse", "HEAD"))

    def test_fetch_moves_from_an_old_branch_to_the_default_branch(self):
        self.git(self.checkout, "checkout", "-q", "main")
        tip = self.publish("26.05")
        self.assertEqual(self.fetch(), ("26.05", tip))

    def test_fetch_follows_the_default_branch_to_a_new_release(self):
        tip = self.publish("26.11")
        self.set_default("26.11")
        self.assertEqual(self.fetch(), ("26.11", tip))
        tip = self.publish("26.11")
        self.assertEqual(self.fetch(), ("26.11", tip), "later fetches keep pulling the release")


if __name__ == "__main__":
    unittest.main()
