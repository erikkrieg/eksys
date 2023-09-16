# Desc: AI on the command line. Uses OpenAI or LocalAI.
# Source: https://github.com/charmbracelet/mods
{ unstable_pkgs, ... }: with unstable_pkgs; {
  home.packages = [
    mods
    glow # Render markdown "nicely" in terminal
  ];
  home.file.".config/mods" = {
    source = ./config;
    recursive = true;
  };
}
