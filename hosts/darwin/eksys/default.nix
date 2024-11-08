{ pkgs, ... }: {
  homebrew = {
    casks = [
      "obs" # video recording and live streaming
      "shotcut" # video editing
      "appflowy" # Notion-like app that I'm testing
      "raspberry-pi-imager" # for flashing SD cards for Raspberry Pi
    ];
  };

  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

  # Disabling until I'm ready to commit to replacing wg with tailscale
  # services.tailscale.overrideLocalDns = true;
}
