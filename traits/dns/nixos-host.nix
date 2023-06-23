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
    enable = true;
    mutableSettings = false;
    settings = {
      bind_port = dns_ui_port;
      bind_host = "0.0.0.0";
      theme = "dark";
      dns = {
        port = dns_port;
        bind_hosts = [ "0.0.0.0" ];
        bootstrap_dns = [ "1.1.1.1" "8.8.8.8" ];
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
        ];
        enable_dnssec = true;
        ratelimit = 100;
      };
      filters = [
        {
          enabled = true;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          id = 1;
        }
        {
          enabled = true;
          name = "AdAway Default Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          id = 2;
        }
      ];
    };
  };
}
