{ config, lib, ... }: {
  programs.zellij = {
    enable = true;
    # Auto-start is added below instead, so it can skip Codex shells.
    enableZshIntegration = false;
  };

  # Same position in .zshrc as Home Manager's own integration (mkOrder 200).
  programs.zsh.initContent = lib.mkOrder 200 ''
    # Codex starts hidden interactive shells (CODEX_SHELL=1) to read the
    # environment, then closes them. Auto-starting zellij there leaves a
    # detached session running in the background for each one.
    if [[ -z "$CODEX_SHELL" ]]; then
      eval "$(${lib.getExe config.programs.zellij.package} setup --generate-auto-start zsh)"
    fi
  '';

  home.file.".config/zellij" = {
    source = ./config;
    recursive = true;
  };
}
