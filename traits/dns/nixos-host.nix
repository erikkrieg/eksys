{ ... }:
let
  dns_port = 53;
  dns_ui_port = 9002;
in
{
  networking.firewall = {
    allowedTCPPorts = [ dns_port dns_ui_port ];
    allowedUDPPorts = [ dns_port ];
  };
  services.adguardhome = {
    enabled = true;
    mutableSettings = false;
    settings = {
      bind_port = dns_ui_port;
      bind_host = "0.0.0.0";
      dns = {
        port = dns_port;
        bind_host = [ "0.0.0.0" ];
        bootstrap_dns = [ "1.1.1.1" "8.8.8.8" ];
      };
    };
  };
}
