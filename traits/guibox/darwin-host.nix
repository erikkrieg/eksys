{ pkgs, ... }: with pkgs; {
  # Configure Finder 
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Homebrew is included to install packages that are missing from nixpkgs
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    casks = [
      "1password"
      "android-file-transfer"
      "anytype" # Notion-like app that I'm testing
      "appflowy" # Notion-like app that I'm testing
      "brave-browser"
      "spotify"
      "discord"
      "balenaetcher"
      "obsidian"
      "sigmaos"
      "slack"
    ];
    onActivation = {
      cleanup = "zap";
      upgrade = true;
      autoUpdate = true;
    };
  };

  environment.systemPath = [ "/opt/homebrew/bin" ];

  # System packages end up in /Applications and can be opened with Spotlight
  # if `nobrowse` is removed from `/etc/fstab`
  environment.systemPackages = [ alacritty ];

  services = {
    yabai = {
      # Interested in trying this out, but going to need to spike on it a bit first.
      enable = false;
    };
  };
}
