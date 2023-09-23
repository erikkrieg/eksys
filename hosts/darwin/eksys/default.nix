{ ... }: {
  homebrew = {
    casks = [
      "obs" # video recording and live streaming
      "shotcut" # video editing
    ];
  };

  # Disabling until I'm ready to commit to replacing wg with tailscale
  # services.tailscale.overrideLocalDns = true;
}
