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
    initExtraFirst = ''
      # Avoid bindkey conflicts with other plugins like fzf. For more info:
      # - https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands
      # - https://github.com/jeffreytse/zsh-vi-mode#initialization-mode
      ZVM_INIT_MODE=sourcing
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      export DELTA_FEATURES=+default
    '';

    initExtra = ''
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
      nixup = "pushd ~/Projects/eksys; nix flake update; nixswitch; popd";
    };
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };

}
