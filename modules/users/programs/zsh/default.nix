{ pkgs, ... }: with pkgs; {
  programs.zsh = {
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

    # Note: not all zsh aliases are defined here. 
    # Some aliases are defined by other user imports from ./programs, 
    # such as git aliases.
    shellAliases = { 
      c = "clear";
      ls = "exa --group-directories-first";
      l = "ls -la --git";
      v = "nvim";
      vf = "nvim \"$(fzf)\"";
      tree="ls --tree -a -I='.git'";
      tree2="tree --level=2";
      tree3="tree --level=3";
      tree4="tree --level=4";
      nixswitch = "darwin-rebuild switch --flake ~/Projects/eksys/.#";
    };
  };

  home.file.".config/zsh" = {
    source = ./config;
    recursive = true;
  };
}
