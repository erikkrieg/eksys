# NixOS or Darwin devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, unstable_pkgs, ... }: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/btop
    ./programs/delta
    ./programs/eza
    ./programs/fzf
    ./programs/genimg
    ./programs/git
    ./programs/kubernetes
    ./programs/mods
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
    unstable_pkgs.nix-du
    graphviz # used in combination with nix-du

    # Network utilities
    dig
    gping

    # Cross-project packages
    devbox
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
