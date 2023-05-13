{ pkgs, envim, ... }: with pkgs; {
  home.packages = [
    envim

    # Dependencies for plugins (consider moving into envim flake directly)
    tree-sitter
    nodejs-slim_20
    fzf
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
