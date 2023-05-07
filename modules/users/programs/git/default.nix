{ pkgs, ... }: with pkgs; {
  programs.git = {
    enable = true;
    userEmail = "10244162+erikkrieg@users.noreply.github.com";
    userName = "Erik Krieg";
    extraConfig = {
      core = {
        editor = "nvim";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };

  programs.zsh.shellAliases = {
    g = "git";
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

  # home.file.".gitconfig".source = ./config/.gitconfig;
}
