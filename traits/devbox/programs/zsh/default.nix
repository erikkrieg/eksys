{ pkgs, ... }: with pkgs; {
  imports = [
    ./completions.nix
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    history.size = 50000;

    # initExtraBeforeCompInit = '''';
    initExtraFirst = ''
      # Avoid bindkey conflicts with other plugins like fzf. For more info:
      # - https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands
      # - https://github.com/jeffreytse/zsh-vi-mode#initialization-mode
      ZVM_INIT_MODE=sourcing
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

      # Provide a simple option for extending the shell outside of source code.
      if [ -d ~/.config/zsh-extra/functions ]; then
        fpath=($fpath ~/.config/zsh-extra/functions)
      fi
    '';

    initExtra = ''
      # Using zsh-fast-syntax-hightlighing instead of zsh-syntax-highlighting
      # because it works bettwe with zsh-vi-mode plugin.
      # See: https://github.com/erikkrieg/eksys/issues/8
      source ~/.config/zsh/prompt.zsh
      source ${zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

      # Provide a simple option for extending the shell outside of source code.
      if [ -f ~/.config/zsh-extra/init.zsh ]; then
        . ~/.config/zsh-extra/init.zsh
      fi
    '';

    # Note: not all zsh aliases are defined here. 
    # Some aliases are defined by other user imports from ./programs, 
    # such as git aliases.
    shellAliases = {
      c = "clear";
      l = "ls -la";
      nixswitch = "darwin-rebuild switch --flake ~/Projects/nix/eksys/.#";
      nixup = "pushd ~/Projects/nix/eksys; nix flake update; nixswitch; popd";
    };
  };

  home.file = {
    ".config/zsh" = {
      source = ./config;
      recursive = true;
    };
  };

}
