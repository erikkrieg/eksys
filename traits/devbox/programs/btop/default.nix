{ pkgs, ... }: with pkgs; {
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "tokyo-night";
      vim_keys = true;
    };
  };

  # Themes are expected in "~/.config/btop/themes" or in "../share/btop/themes" 
  # relative to binary but on Darwin this relative path doesn't seem to work.
  # Fixing this by creating a symlink to .config dir. 
  home.file.".config/btop/themes" = {
    source = "${btop}/share/btop/themes";
    recursive = true;
  };
}
