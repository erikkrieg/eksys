{ pkgs, ... }: {
  programs.git.delta = {
    enable = true;
    options = {
      navigate = true;
      light = false;
      dark = true;
      syntax-theme = "DarkNeon";
      default = {
        side-by-side = true;
      };
      preview = {
        side-by-side = false;
      };
    };
  };

  programs.zsh.initContent = pkgs.lib.mkBefore ''
    export DELTA_FEATURES=+default
  '';
}
