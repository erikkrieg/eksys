# NixOS-specific server host configuration.
# https://search.nixos.org/options
{ config, pkgs, ... }: with pkgs; {
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

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  systemd.services.tailscale-up = {
    after = [ "tailscale.service" "k3s.service" ];
    wants = [ "tailscale.service" "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
      if [[ $status != Connected* ]]; then
        auth="$(${kubectl}/bin/kubectl exec deploy/headscale -n headscale -- headscale authkeys create -u server --expiration 5m)"
        ${tailscale}/bin/tailscale up --auth-key $auth --login-server=http://127.0.0.1:30080
      fi
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
