{ lib, ... }: {
  homebrew = {
    casks = [
      "google-chrome"
      "raycast"
    ];
  };

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
  services.tailscale.enable = lib.mkForce false;
}
