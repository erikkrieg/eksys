{ ... }: {
  programs.git.delta = {
    enable = true;
    options = {
      navigate = true;
      light = false;
      syntax-theme = "DarkNeon";
      default = {
        side-by-side = true;
      };
      preview = {
        side-by-side = false;
      };
    };
  };

  programs.zsh.initExtraFirst = ''
    export DELTA_FEATURES=+default
  '';
}

