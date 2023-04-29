# Configure user space using home-manager.
# https://nix-community.github.io/home-manager/options.html
{pkgs, ...}: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
  ];

  # Install user-specific packages
  home.packages = [
    # Utility packages
    bat
    btop
    delta
    fd
    jq
    ripgrep
    gh

    # Cross-project packages
    # alacritty 
    just
    neovim
    zellij 

    # Language-specific
    nodePackages.bash-language-server
    shellcheck 
    pipenv
  ];

  # Allows for exporting shell vars.
  # Not sure if I'd rather use this or just have a .zshrc file
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Configure select packages that have direct home-manager options.
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
    exa.enable = true;
    git.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    # Configure zsh shell
    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      history.size = 50000;
      # initExtraBeforeCompInit = '''';
      # initExtraFirst = '''';
      initExtra = ''
        source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ~/.config/zsh/prompt.zsh
        eval "$(zellij setup --generate-auto-start zsh)"
      '';
      shellAliases = { 
        c = "clear";
        ls = "exa --group-directories-first";
        l = "ls -la --git";
        v = "nvim";
        vf = "nvim \"$(fzf)\"";
        gs = "git status";
        gd = "git diff";
        gl = "git pull";
        gp = "git push";
        ga = "git add";
        gf = "git fetch";
        gco = "git checkout";
        gcb = "git checkout -b";
        gcam = "git commit --all --message";
        gcmsg = "git commit --message";
        tree="ls --tree -a -I='.git'";
        tree2="tree --level=2";
        tree3="tree --level=3";
        tree4="tree --level=4";
        nixswitch = "darwin-rebuild switch --flake ~/Projects/eksys/.#";
      };
    };

    # alacritty = {
    #   enable = true;
    # };
  };

  # Configure terminal emulator.
  # Not sure I want to configure it like this. I think I'd rather
  # have alacritty as a home package with a config file symlinked
  # to .config/alacritty/
  # programs.alacritty = { enable = true; settings.font.size = 16; };

  home.file = {
    ".inputrc".source = ./dotfiles/.inputrc;
    ".config/zsh/prompt.zsh".source = ./dotfiles/zsh/prompt.zsh;
    ".gitconfig".source = ./dotfiles/.gitconfig;
  };
}
