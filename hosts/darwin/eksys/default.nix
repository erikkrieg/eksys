{ ... }: {
  homebrew = {
    casks = [
      "obs" # video recording and live streaming
      "shotcut" # video editing
      "appflowy" # Notion-like app that I'm testing
    ];
  };

  # Disabling until I'm ready to commit to replacing wg with tailscale
  # services.tailscale.overrideLocalDns = true;
}
