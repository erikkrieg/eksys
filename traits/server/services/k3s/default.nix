{ config, ... }: {
  imports = [ ./longhorn.nix ];
  services.k3s = {
    # enable = true;
    enable = false;
    role = "server";
    configPath = ./server.yaml;
    clusterInit = true;
    extraFlags = ''--node-label "host=${config.networking.hostName}"'';
  };

  # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodes
  networking.firewall.allowedTCPPorts = [
    80
    443

    2379 # Required for HA
    2380 # Required for HA
    6443 # K3s supervisor and Kubernetes API Server
    10250 # Kubelet metrics
  ];
  networking.firewall.allowedUDPPorts = [
    8472 # Required only for Flannel VXLAN
  ];

  # This is referenced by tailscale config which would need to be updated
  # if the way kubeconfig path is set changes.
  environment.sessionVariables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
}
