"""Behavior tests for the rebuild workflow.

Real Nix evaluates, locks, and builds disposable flakes in a temporary
directory. Only machine identity, GitHub authentication, and the privileged
activation step are faked, so the tests observe results rather than the
commands used to produce them.
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

# A buildable stand-in for a host system. It builds offline from a local file,
# so a rebuild reaches activation without any real host configuration.
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
        url = "file://${builtins.toFile "content" dependency.content}";
        outputHashAlgo = "sha256";
        outputHashMode = "flat";
        outputHash = builtins.hashString "sha256" dependency.content;
      };
    in {
      darwinConfigurations = {
        ek_pro.system = system "ek_pro";
        spare.system = system "spare";
      };
    };
}
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
        self.state = self.repo / "state"
        fakes = self.repo / "fakes.sh"
        fakes.write_text(f"""
hostname() {{ echo "${{FAKE_HOST:-unmatched-hostname}}"; }}
uname() {{ echo Darwin; }}
gh() {{ echo synthetic-token; }}
sudo() {{ echo activated >> "{self.activations}"; }}
nix() {{ "{NIX}" --offline "$@"; }}
""")
        self.env = {
            "PATH": os.pathsep.join((str(Path(JUST).parent), "/usr/bin", "/bin")),
            "HOME": str(self.repo),
            "BASH_ENV": str(fakes),
            "XDG_STATE_HOME": str(self.state),
            "NIX_CONF_DIR": str(self.repo / "no-system-settings"),
            "NIX_USER_CONF_FILES": "/dev/null",
        }

    def remembered(self):
        target = self.state / "eksys" / "target"
        return target.read_text().strip() if target.exists() else None

    def run_command(self, *args, **env):
        return subprocess.run(args, cwd=self.repo, env=dict(self.env, **env),
                              capture_output=True, text=True)

    def activation_count(self):
        return len(self.activations.read_text().split()) if self.activations.exists() else 0


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
        self.dependencies = {}
        for name in ("dependency", "extra"):
            path = self.repo / name
            path.mkdir()
            (path / "flake.nix").write_text(
                '{ outputs = { self }: { content = "%s"; }; }\n' % name)
            self.dependencies[name] = path
        self.lock = self.repo / "flake.lock"
        (self.repo / "flake.nix").write_text(
            SYSTEM % (self.dependencies["dependency"], self.dependencies["extra"]))
        result = self.run_command("/bin/bash", "scripts/nix.sh", "flake", "lock")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_rebuild_activates_the_selected_and_requested_targets(self):
        result = self.run_command(JUST, "b")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activation_count(), 1)
        result = self.run_command(JUST, "bt", "spare")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.activation_count(), 2)

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
        self.assertEqual(self.activation_count(), 2)

    def test_a_target_is_not_remembered_when_the_rebuild_fails(self):
        result = self.run_command(JUST, "bt", "no_such_host")
        self.assertNotEqual(result.returncode, 0)
        self.assertIsNone(self.remembered())

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
