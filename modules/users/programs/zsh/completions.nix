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
      # Not sure why, but if I don't provide all the fzf-preview args then the
      # values actually change which impacts the manual previews.
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'preview.sh $realpath $word $words $group'
      zstyle ':fzf-tab:complete:*:options' fzf-preview ""
    '';
  };

  home.file.".local/bin/preview.sh" = {
    executable = true;
    text = ''
      #!${zsh}/bin/zsh
      case "$1" in
        -*) exit 0;;
      esac

      if [ -e "$1" ]; then
        case "$(${file}/bin/file -L --mime-type "$1")" in
          *text*)
            ${bat}/bin/bat --color always --plain "$1"
            ;;
          *image* | *pdf)
            ${catimg}/bin/catimg -w 100 -r 2 "$1"
            ;;
          *directory*)
            ${exa}/bin/exa --icons -1 --color=always "$1"
            ;;
          *)
            echo "unknown file format"
            ;;
        esac
      else
        BATMAN="${bat-extras.batman}/bin/batman"
        if ! BATMAN "$2-$1" 2>/dev/null; then 
          BATMAN "$1"
        fi
      fi
    '';
  };
}
