# NixOS or Darwin devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, ... }: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/btop
    ./programs/delta
    ./programs/exa
    ./programs/fzf
    ./programs/git
    ./programs/kubernetes
    ./programs/nvim
    ./programs/taskwarrior
    ./programs/zellij
    ./programs/zoxide
    ./programs/zsh
  ];

  # Install user-specific packages
  home.packages = [
    # Utility packages
    catimg
    delta
    fd
    jq
    ripgrep
    gh
    nix-tree

    # Network utilities
    dig
    gping

    # Cross-project packages
    just

    # Language-specific
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

  # There are some home manager programs that depend on xdg paths
  xdg.enable = true;
}
