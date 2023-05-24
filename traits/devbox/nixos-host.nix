# NixOS-specific devbox host configuration.
# https://search.nixos.org/options
{ ... }: {
  imports = [ ./common-host.nix ];
}
