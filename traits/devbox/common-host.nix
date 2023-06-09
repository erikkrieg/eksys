# Configuration that is common between NixOS and nix-darwin. Ensure attributes
# produce the desired effect on both systems!
# - https://search.nixos.org/options
# - https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, ... }: with pkgs; {
  nix.extraOptions = ''experimental-features = nix-command flakes'';

  # Configure shells
  programs.zsh = {
    enable = true;
    # Only use basic config at system level to avoid conflicts with user configs.
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "PROMPT='%/ ❯ '"; # Default value conflicted with user's prompt.
  };
  environment.shells = [ bash zsh ];

  environment.systemPackages = [
    coreutils
    git
    neofetch
    wireguard-tools

    # Alternatives to du
    du-dust
    ncdu

    # System security tooling
    lynis
  ];

  # Configure fonts
  fonts = {
    fontDir.enable = true; # Danger: `true` mean fonts can get removed.
    fonts = [ (nerdfonts.override { fonts = [ "Meslo" ]; }) ];
  };
}
