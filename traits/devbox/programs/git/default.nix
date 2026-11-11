{ pkgs, ... }: with pkgs; {
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "10244162+erikkrieg@users.noreply.github.com";
        name = "Erik Krieg";
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

  # Based on OMZ git aliases
  # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git
  programs.zsh.shellAliases = {
    g = "git";
    gb = "git branch";
    gbd = "git branch -d";
    gbD = "git branch -D";
    gs = "git status";
    gd = "git diff";
    gl = "git pull";
    ggl = "git pull origin $(git branch --show-current)";
    gp = "git push";
    ggp = "git push origin $(git branch --show-current)";
    ga = "git add";
    gf = "git fetch";
    gco = "git checkout";
    gcb = "git checkout -b";
    gcam = "git commit -am";
    gcmsg = "git commit -m";
    gm = "git merge";
  };
}

