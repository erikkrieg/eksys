{ ... }: {
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
      "android-file-transfer"
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

  services = {
    yabai = {
      # Interested in trying this out, but going to need to spike on it a bit first.
      enable = false;
    };
  };
}
