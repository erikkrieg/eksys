{ ... }: {
  programs.alacritty = {
    enable = true;
  };
  home.file.".config/alacritty" = {
    source = ./config;
    recursive = true;
  };
}

