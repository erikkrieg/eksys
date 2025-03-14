{ pkgs, ... }: with pkgs; {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "${ripgrep}/bin/rg --files --hidden --glob '!.git'";
    defaultOptions = [
      "--height=60%"
      "--layout=reverse"
      "--border"
      "--margin=1"
      "--padding=1"
    ];
  };

  programs.zsh.initExtra = ''
    # Ensure the fzf managed by nix is used.
    function __fzfcmd() {
      [ -n "$TMUX_PANE" ] && { [ "$FZF_TMUX" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
        echo "${fzf}/bin/fzf-tmux $FZF_TMUX_OPTS -- " || echo "${fzf}/bin/fzf"
    }
  '';
}
