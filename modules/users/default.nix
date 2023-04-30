# Configure user space using home-manager.
# https://nix-community.github.io/home-manager/options.html
{pkgs, ...}: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/exa
    ./programs/git
    ./programs/zellij
    ./programs/zoxide
    ./programs/zsh
  ];

  # Install user-specific packages
  home.packages = [
    # Utility packages
    btop
    delta
    du-dust
    fd
    jq
    ripgrep
    gh

    # Cross-project packages
    just
    neovim

    # Language-specific
    nodePackages.bash-language-server
    shellcheck 
    pipenv
  ];

  # Allows for exporting shell vars.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden --glob '!.git'";
      defaultOptions = [
        "--height=60%"
        "--layout=reverse"
        "--border"
        "--margin=1"
        "--padding=1"
      ];
    };

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
