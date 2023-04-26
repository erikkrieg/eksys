# Configure user space using home-manager.
# https://nix-community.github.io/home-manager/options.html
{pkgs, ...}: with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  # Install user-specific packages
  home.packages = [
    btop
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
    };
    exa.enable = true;
    git.enable = true;

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
        nixswitch = "darwin-rebuild switch --flake ~/Projects/eksys/.#";
      };
    };
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
