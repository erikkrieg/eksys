{ pkgs, ... }: with pkgs; {
  # Configure Finder 
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Homebrew is included to install packages that are missing from nixpkgs
  homebrew = {
    enable = true;
    global.brewfile = true;
    casks = [
      "1password"
      "android-file-transfer"
      "anytype" # Notion-like app that I'm testing
      "balenaetcher"
      "brave-browser"
      "chatgpt"
      "discord"
      "obsidian"
      "raycast"
      "sigmaos"
      "spotify"
    ];
    onActivation = {
      cleanup = "none";
      # brew bundle upgrades each cask in its own brew process, and each one
      # resets the sudo timestamp, so upgrading here would ask for the password
      # once per outdated cask. `just upgrade-apps` upgrades them in one run.
      upgrade = false;
      autoUpdate = false;
      extraFlags = [ "--force-cleanup" "--zap" ];
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
