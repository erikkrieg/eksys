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
      # zsh-vi-mode creates a number of bindkeys that get initialized with 
      # precmd_functions, which is run before each prompt is displayed. This
      # was interfering with a fzf bindkey that I wanted while in insert mode.
      function unset_zsh_vi_mode_history_bindkey() {
        zvm_bindkey viins '^R' fzf-history-widget
      } 
      precmd_functions+=(unset_zsh_vi_mode_history_bindkey)

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
