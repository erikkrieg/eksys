{ pkgs, ... }: with pkgs; {
  programs.zsh = {
    enableCompletion = true;
    completionInit = ''
      autoload -U compinit 
      zstyle ':completion:*' menu select
      zstyle ':completion:*' menu yes select
      zstyle ':completion:*' sort false
      zstyle ':completion:*' completer _complete _match _approximate
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'
      zstyle ':completion:*' special-dirs true
      zstyle ':completion:*' rehash true
      zstyle ':completion:*' list-grouped false
      zstyle ':completion:*' list-separator '''
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*' file-sort modification
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:matches' group 'yes'
      zstyle ':completion:*:warnings' format '%F{red}%B-- No match for: %d --%b%f'
      zstyle ':completion:*:messages' format '%d'
      zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
      zstyle ':completion:*:match:*' original only
      zstyle ':completion:*:approximate:*' max-errors 1 numeric
      zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
      zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
      zstyle ':completion:*:jobs' numbers true
      zstyle ':completion:*:jobs' verbose true
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:exa' sort false
      zstyle ':completion:complete:*:options' sort false
      zstyle ':completion:files' sort false
      compinit
    '';

    initExtra = ''
      source ${zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      FZF_TAB_COMMAND=(
        ${fzf}
        --ansi
        --expect='$continuous_trigger'
        --nth=2,3 --delimiter='\x00'
        --layout=reverse --height="''${FZF_TMUX_HEIGHT:=60%}"
        --tiebreak=begin -m --bind=tab:down,btab:up,change:top,ctrl-space:toggle --cycle
        '--query=$query'
        '--header-lines=$#headers'
      )
      zstyle ':fzf-tab:*' command $FZF_TAB_COMMAND
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:complete:_zlua:*' query-string input
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'preview.sh $realpath $word $words $group'
      zstyle ':fzf-tab:complete:*:options' fzf-preview 
    '';
  };

  # Keep most of the script outside the string to take advantage of LSPs
  home.file.".local/bin/preview.sh" = {
    executable = true;
    text = ''
      #!${zsh}/bin/zsh
      FILE=${file}/bin/file
      BAT=${bat}/bin/bat
      CATIMG=${catimg}/bin/catimg
      EXA=${exa}/bin/exa
      BATMAN=${bat-extras.batman}/bin/batman
      GIT=${git}/bin/git
      DELTA=${delta}/bin/git
      ${builtins.readFile ./config/preview.zsh}
    '';
  };
}
