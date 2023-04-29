{ ... }: {
  programs.git = {
    enable = true;
  };

  programs.zsh.shellAliases = {
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
  };

  home.file.".gitconfig".source = ./config/.gitconfig;
}
