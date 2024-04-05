# Configuration that is common between NixOS and nix-darwin. Ensure attributes
# produce the desired effect on both systems!
# - https://search.nixos.org/options
# - https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, lib, ... }: with pkgs;
let
  fonts = [ (nerdfonts.override { fonts = [ "Meslo" ]; }) ];
in
{
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

  environment.variables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

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
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    fonts = fonts;
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    packages = fonts;
  };

  # Show changes after a rebuild.
  # https://gist.github.com/luishfonseca/f183952a77e46ccd6ef7c907ca424517?permalink_comment_id=4620275#gistcomment-4620275 
  system.activationScripts.postUserActivation = {
    text = ''
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
    '';
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    supportsDryActivation = true;
  };
}
