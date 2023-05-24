{ config, ... }: {
  services.k3s = {
    enable = true;
    role = "server";
    configPath = ./server.yaml;
    extraFlags = ''--node-label "host=${config.networking.hostName}"'';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.sessionVariables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };
}
