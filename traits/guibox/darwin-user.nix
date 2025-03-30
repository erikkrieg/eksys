# Darwin-specific guibox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ claude-code, ... }: {
  home.packages = [
    claude-code
  ];
}
