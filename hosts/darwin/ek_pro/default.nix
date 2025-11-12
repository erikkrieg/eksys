{ pkgs, lib, ... }:
let
  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];
in
{
  # Using determinate nix to run the nix daemon instead of nix-darwin
  nix.enable = false;

  homebrew = {
    casks = [
      "tuple"
    ];
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    gcloud
    ipmitool
  ];

  # Changing the binary for sh can conflict with IT tools
  system.activationScripts.setDashAsSh.enable = false;

  services.tailscale.enable = lib.mkForce false;

  system.primaryUser = "ekrieg";
}
