# Darwin-specific devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ ... }: {
  imports = [
    ./common-user.nix
  ];
}
