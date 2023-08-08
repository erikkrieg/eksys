# Darwin-specific devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, unstable_pkgs, ... }: {
  imports = [
    ./common-user.nix
  ];

  home.packages = [
    unstable_pkgs.colima
    pkgs.docker
  ];
}
