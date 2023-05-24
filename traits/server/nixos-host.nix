# NixOS-specific server host configuration.
# https://search.nixos.org/options
{ pkgs, ... }: with pkgs; {
  imports = [ ];

  # This is to demonstrate how nixos offers support for k3s. But, I want to set this
  # a bit more directly first and then may migrate to this when I know what I want.
  # Ref: https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=k3s
  # services.k3s = {
  #   enable = true;
  #   role = "server"; # Server also acts as an agent.
  # };

  environment.systemPackages = [
    k3s
  ];


  security.sudo.execWheelOnly = true;
}
