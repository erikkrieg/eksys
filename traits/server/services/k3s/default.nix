{ ... }: {
  services.k3s = {
    enable = true;
    role = "server";
    configPath = ./server.yaml;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.sessionVariables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };
}
