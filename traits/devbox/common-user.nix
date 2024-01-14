# NixOS or Darwin devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, ... }:
let
  genimg = pkgs.writeShellScriptBin "genimg" ''
    #!/bin/bash

    temp_file=$(mktemp)
    trap 'rm -f -- "$temp_file"' EXIT

    curl https://api.openai.com/v1/images/generations \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
     "model": "dall-e-3",
     "prompt": "'"$1"'",
     "n": 1,
     "size": "1792x1024"
     }' | ${pkgs.jq}/bin/jq -r '.data[0].url' >"$temp_file"

    image_url=$(cat "$temp_file")
    open "$image_url"
    ${pkgs.wget}/bin/wget -P . "$image_url"
  '';
in
with pkgs; {
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/btop
    ./programs/delta
    ./programs/exa
    ./programs/fzf
    ./programs/git
    ./programs/kubernetes
    ./programs/mods
    ./programs/nvim
    ./programs/taskwarrior
    ./programs/zellij
    ./programs/zoxide
    ./programs/zsh
  ];

  # Install user-specific packages
  home.packages = [
    # Utility packages
    catimg
    delta
    fd
    jq
    ripgrep
    gh
    nix-tree
    genimg

    # Network utilities
    dig
    gping

    # Cross-project packages
    devbox
    just

    # Language-specific
    pipenv
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };

  home.file = {
    ".inputrc".source = ./dotfiles/.inputrc;
  };

  # There are some home manager programs that depend on xdg paths
  xdg.enable = true;
}
