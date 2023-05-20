# NixOS or Darwin devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, ... }: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/delta
    ./programs/exa
    ./programs/fzf
    ./programs/git
    ./programs/kubernetes
    ./programs/nvim
    ./programs/zellij
    ./programs/zoxide
    ./programs/zsh
  ];

  # Install user-specific packages
  home.packages = [
    # Utility packages
    btop
    catimg
    delta
    du-dust
    fd
    jq
    ripgrep
    gh

    # Cross-project packages
    just

    # Language-specific
    nodePackages.bash-language-server
    shellcheck
    pipenv
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };

  home.file = {
    ".inputrc".source = ./dotfiles/.inputrc;
  };
}
