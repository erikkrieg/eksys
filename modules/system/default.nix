# Configure Darwin system space.
# https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, ... }: with pkgs; {
  # Backwards compatibility. Don't change.
  system.stateVersion = 4;

  # Configure shells
  programs.zsh.enable = true;
  environment.shells = [ dash bash zsh ];
  environment.loginShell = zsh;

  # Configure nix
  # Essentially contents of ~/.config/nix/nix.conf
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  services.nix-daemon.enable = true; # Allow nix-darwin to manages/updates the daemon

  # Install system packages (available to all users)
  environment.systemPackages = [ coreutils ];

  # Configure keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Configure fonts
  fonts = {
    fontDir.enable = false; # Danger: `true` mean fonts can get removed.
    fonts = [ (nerdfonts.override { fonts = ["Meslo"]; }) ];
  };

  # Configure Finder 
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };
}
