{ pkgs, lib, ... }:
let
  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];
in
{
  homebrew = {
    casks = [ ];
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    gcloud
    ipmitool
    sshpass
  ];

  services.tailscale.enable = lib.mkForce false;

  system.primaryUser = "ekrieg";
}
