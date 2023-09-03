{ ... }: {
  homebrew = {
    casks = [
      "obs" # video recording and live streaming
      "shotcut" # video editing
    ];
  };

  services.tailscale.overrideLocalDns = true;
}
