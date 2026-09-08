{ ... }: {
  homebrew = {
    casks = [
      "chatgpt" # GUI
      "obs" # video recording and live streaming
      "shotcut" # video editing
      "appflowy" # Notion-like app that I'm testing
      "raspberry-pi-imager" # for flashing SD cards for Raspberry Pi
      "ghostty" # terminal emulator
      "slack"
    ];
  };

  determinateNix = {
    customSettings = {
      trusted-users = [ "root" ];
      max-jobs = "auto";
      cores = 0;
    };
    determinateNixd = {
      builder.state = "disabled";
      garbageCollector.strategy = "automatic";
    };
  };
  system.primaryUser = "ek";

  # Disabling until I'm ready to commit to replacing wg with tailscale
  # services.tailscale.overrideLocalDns = true;
}
