# NixOS or Darwin vpn-peer host configuration via nixos or nix-darwin:
# - https://search.nixos.org/options
# - https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, ... }: with pkgs; {
  environment.systemPackages = [
    wireguard-tools
    wireguard-go
  ];
}
