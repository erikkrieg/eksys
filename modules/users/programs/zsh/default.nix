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

    home.file.".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };
}
