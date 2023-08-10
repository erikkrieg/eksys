{ config, pkgs, ... }: with pkgs; {
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
      function up() {
        status=$(${config.systemd.package}/bin/systemctl show -P StatusText tailscaled.service)
        if [[ $status != Connected* ]]; then
          export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
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
