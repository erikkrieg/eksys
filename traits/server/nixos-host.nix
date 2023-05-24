# NixOS-specific server host configuration.
# https://search.nixos.org/options
{ ... }: {
  imports = [
    ./services/k3s
  ];

  security.sudo.execWheelOnly = true;

  services.openssh = {
    enable = true;
    allowSFTP = false;
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
}
