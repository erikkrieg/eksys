{ pkgs, envim, ... }: with pkgs; {
  home.packages = [
    envim

    # Packages that are needed in the path for nvim plugins used by envim.
    # Unfortunately I don't konw how to install these on the PATH within the envim flake.
    shellcheck # used by bash-language-server
    unzip # needed to install cmp-tabnine
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
