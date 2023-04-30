{ ... }: {
  programs.zellij = {
    enable = true;
  };

  programs.zsh.initExtra = ''
    eval "$(zellij setup --generate-auto-start zsh)"
  '';

  home.file.".config/zellij" = {
    source = ./config;
    recursive = true;
  };
}
