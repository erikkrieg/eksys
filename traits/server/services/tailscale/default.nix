{ config, pkgs, ... }: with pkgs; {
  services.tailscale = {
    enable = true;
    authKeyFile = "/run/secrets/tailscale_key"; # This auth key needs to be manually created
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node"
      "--advertise-routes=10.42.0.0/16,10.43.0.0/16"
      "--accept-routes=false"
      "--ssh"
      "--reset"
    ];
  };

  # This was previously being used to test communication between k3s nodes over
  # Tailscale. It is no longer needed, but I'm keeping it around for reference.
  systemd.services.tailscale-up = {
    # enable = config.services.k3s.enable && config.services.tailscale.enable;
    enable = false;
    after = [ "tailscale.service" "k3s.service" ];
    wants = [ "tailscale.service" "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      function up() {
        status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
        if [[ $status != Connected* ]]; then
          export KUBECONFIG=${config.environment.sessionVariables.KUBECONFIG}
          auth="$(${kubectl}/bin/kubectl exec deploy/headscale -n headscale -- \
            headscale authkey create -u server  --expiration 5m)"
          ${tailscale}/bin/tailscale up \
            --auth-key $auth \
            --login-server=http://127.0.0.1:30080 \
            --advertise-exit-node \
            --advertise-routes=192.168.1.0/24 \
            --accept-routes=false \
            --ssh \
            --reset
        fi
      }
      up || exit 0
    '';
  };
}
