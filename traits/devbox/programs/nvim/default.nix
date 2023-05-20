{ pkgs, envim, ... }: with pkgs; {
  home.packages = [
    envim
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.zsh.shellAliases = {
    v = "nvim";
    vf = "nvim \"$(fzf)\"";
  };

  programs.git = {
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
