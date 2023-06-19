# NixOS-specific server host configuration.
# https://search.nixos.org/options
{ pkgs, ... }: with pkgs; {
  imports = [
    ./services/k3s
  ];

  security.sudo.execWheelOnly = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = false;
    };
    extraConfig = ''
      AllowTcpForwarding yes
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  environment.systemPackages = [
    wireguard-tools

    # Alternatives to du
    du-dust
    ncdu

    # System security tooling
    lynis
  ];

  nix.gc.automatic = true;
  nix.optimise.automatic = true;
}
