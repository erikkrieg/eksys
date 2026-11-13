{ pkgs, envim, ... }: with pkgs; {
  home.packages = [
    envim

    # Packages that are needed in the path for nvim plugins used by envim.
    # Unfortunately I don't konw how to install these on the PATH within the envim flake.
    shellcheck # used by bash-language-server
    unzip # needed to install cmp-tabnine

    # envim only puts rumdl on nvim's PATH; this one is for the shell.
    rumdl
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
    settings = {
      core = {
        editor = "nvim";
      };
    };
  };

  # rumdl (envim's Markdown LSP) only reads this when a project has no config
  # of its own. A line length of 0 turns MD013 off. MD036 still flags bold
  # lines used as headings, but its fix no longer turns them into headings.
  # rumdl's LSP ignores the global unfixable list, so this uses the rule's own
  # fix option.
  home.file.".config/rumdl/rumdl.toml".text = ''
    [MD013]
    line-length = 0

    [MD036]
    fix = false
  '';
}
