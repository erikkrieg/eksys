{ pkgs, envim, ... }: with pkgs; {
  home.packages = [
    envim

    # Used by bash-language-server (which is installed in envim).
    # I'd rather shellcheck be packaged directly in envim, but I'm not sure how
    # to include it in the path so that the bash ls can access it.
    shellcheck
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
