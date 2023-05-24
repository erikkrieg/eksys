# Configure Darwin system space.
# https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, ... }: with pkgs; {
  imports = [ ./common-host.nix ];

  # Backwards compatibility. Don't change.
  system.stateVersion = 4;

  environment.shells = [ bash zsh ];
  environment.loginShell = zsh;

  # Not sure if there is a better way to do this, but in order to ensure my
  # shell packages installed via nix are being used instead of the MacOS defaults,
  # making a few modifications post activation.
  #
  # The following shell modifications are applied idempotently:
  # 1. sh is linked to dash
  # 2. zsh is set as default shell for root user
  #
  # Set sh to execute dash because it is faster than bash
  # Important: dash is limited to the posix specification, so has fewer 
  # features than bash, which is a superset of posix.
  system.activationScripts.postActivation = {
    text = ''
      echo "post activation..."
      NIX_SYS="/run/current-system/sw"

      # Set sh to dash
      DASH="/bin/dash"
      if [ "$(readlink /var/select/sh)" != "$DASH" ]; then
        echo "  - linking sh to dash because it is a faster shell"
        ln -sf "$DASH" /var/select/sh
      fi

      # Set zsh as the default shell for root user
      ZSH="$NIX_SYS/bin/zsh"
      if [ "$SHELL" != "$ZSH" ]; then
        echo "  - using zsh as default shell for root"
        chsh -s "$ZSH" "$USER"
      fi
    '';
  };

  services.nix-daemon.enable = true; # Allow nix-darwin to manages/updates the daemon

  # Install system packages (available to all users)
  environment.systemPackages = [
    coreutils
  ];

  # Configure keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Configure fonts
  fonts = {
    fontDir.enable = true; # Danger: `true` mean fonts can get removed.
    fonts = [ (nerdfonts.override { fonts = [ "Meslo" ]; }) ];
  };

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
      "brave-browser"
      "spotify"
      "discord"
      "balenaetcher"
      "obsidian"
    ];
    onActivation.cleanup = "zap";
  };
  environment.systemPath = [ "/opt/homebrew/bin" ];
}