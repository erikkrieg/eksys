{ unstable_pkgs, ... }: {
  home.packages = [ unstable_pkgs.teleport ];

  # Disable client tools managed updates since Nix manages the binary.
  # https://goteleport.com/docs/upgrading/client-tools-managed-updates/
  home.sessionVariables = {
    TELEPORT_TOOLS_VERSION = "off";
  };
}
