{ pkgs, ... }: with pkgs; {
  imports = [
    ./completions.nix
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    history.size = 50000;

    # initExtraBeforeCompInit = '''';
    # initExtraFirst = '''';
    initExtra = ''
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      # Try this out later. Seems promising but might be messing up some
      # of my other configurations.
      # For example, my vim prompt map of `cc` no longer enters insert mode after clearing the line
      # when fzf-tab is enabled.
      source ~/.config/zsh/prompt.zsh
    '';

    # Note: not all zsh aliases are defined here. 
    # Some aliases are defined by other user imports from ./programs, 
    # such as git aliases.
    shellAliases = { 
      c = "clear";
      l = "ls -la";
      v = "nvim";
      vf = "nvim \"$(fzf)\"";
      nixswitch = "darwin-rebuild switch --flake ~/Projects/eksys/.#";
    };
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };

}
