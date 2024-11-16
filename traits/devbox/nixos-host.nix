# NixOS-specific devbox host configuration.
# https://search.nixos.org/options
{ pkgs, ... }: with pkgs; {
  imports = [ ./common-host.nix ];

  users.defaultUserShell = zsh;

  security.sudo.wheelNeedsPassword = false;
  security.sudo.execWheelOnly = true;
}
