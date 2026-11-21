# Darwin-specific devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, unstable_pkgs, ... }: {
  imports = [
    ./common-user.nix
  ];

  # Reset the inherited helper and use Apple's to preserve Keychain trust across Nix updates.
  programs.git.settings.credential.helper = [
    ""
    "/Library/Developer/CommandLineTools/usr/libexec/git-core/git-credential-osxkeychain"
  ];

  home.packages = [
    unstable_pkgs.colima
    # 25.11 still defaults docker to docker_28, which is marked insecure.
    pkgs.docker_29
  ];
}
