{ pkgs, lib, ... }:
let
  cacheSettings = import ../../nix-cache-settings.nix;
  gcloud = pkgs.google-cloud-sdk.withExtraComponents [
    pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
  ];
in
{
  # Using determinate nix to run the nix daemon instead of nix-darwin
  nix.enable = false;

  # Determinate reads this file in addition to its own nix.conf.
  # https://docs.determinate.systems/guides/nix-darwin/
  environment.etc."nix/nix.custom.conf".text =
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value:
      "${name} = ${if builtins.isBool value then lib.boolToString value else toString value}"
    ) cacheSettings) + "\n";

  homebrew = {
    casks = [ ];
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    gcloud
    ipmitool
    sshpass
  ];

  # Changing the binary for sh can conflict with IT tools
  system.activationScripts.setDashAsSh.enable = false;

  services.tailscale.enable = lib.mkForce false;

  system.primaryUser = "ekrieg";
}
