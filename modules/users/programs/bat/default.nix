{ pkgs, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
    extraPackages = with pkgs.bat-extras; [
      batman    # Read system manual pages (man) using bat as the manual page formatter.
      batgrep   # Quickly search through and highlight files using ripgrep.
    ];
  };

  programs.zsh = {
    initExtra = ''
      function _fd_bat_batch() {
        fd "''\${@}" -X bat 
      }
    '';
    shellAliases = {
      cat = "bat -pp";
      less = "bat -p";
      batfzf = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
      batfd = "_fd_bat_batch";
    };
  };
}
