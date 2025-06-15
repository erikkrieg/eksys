{ pkgs, ... }:
let
  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];
in
{
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

  system.primaryUser = "ekrieg";
}
