# Configure user space using home-manager.
# https://nix-community.github.io/home-manager/options.html
{pkgs, envim, ...}: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/exa
    ./programs/fzf
    ./programs/git
    ./programs/delta
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
    envim.packages."aarch64-darwin".default

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
