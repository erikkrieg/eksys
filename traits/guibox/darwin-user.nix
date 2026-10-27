# Darwin-specific guibox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ unstable_pkgs, ... }: {
  home.packages = [
    unstable_pkgs.claude-code
  ];
}
