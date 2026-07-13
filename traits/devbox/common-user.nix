# NixOS or Darwin devbox user configuration via home-manager.
# https://nix-community.github.io/home-manager/options.html
{ pkgs, unstable_pkgs, llm_agents, ... }: with pkgs;
let
  buildkite-cli = unstable_pkgs.buildkite-cli.overrideAttrs (old: rec {
    version = "3.36.0";
    src = fetchFromGitHub {
      owner = "buildkite";
      repo = "cli";
      tag = "v${version}";
      hash = "sha256-6cr/kFHtRNeBV8kLu0GYJN0GXehtnRfvnnfPDA2+tcQ=";
    };
    vendorHash = "sha256-lRoMAbU4MrOKycCIM+u2JM+8LNEvdRtQm6ZJu80czUI=";
    doCheck = false;
    postPatch = ''
      patchShebangs .buildkite/{release,tag,upload-packages}.sh
    '';
    subPackages = null;
    postInstall = ''
      mv $out/bin/cli $out/bin/bk
    '';
  });
in
{
  # Backwards compatibility. Don't change.
  home.stateVersion = "22.11";

  imports = [
    ./programs/alacritty
    ./programs/bat
    ./programs/btop
    ./programs/delta
    ./programs/eza
    ./programs/fzf
    ./programs/genimg
    ./programs/git
    ./programs/kubernetes
    ./programs/mods
    ./programs/nvim
    ./programs/taskwarrior
    ./programs/zellij
    ./programs/zoxide
    ./programs/zsh
    ./programs/teleport
  ];

  # Install user-specific packages
  home.packages = [
    autossh

    # Utility packages
    catimg
    delta
    fd
    jq
    ripgrep
    gh
    nix-tree
    graphviz # used in combination with nix-du
    unstable_pkgs.nix-du
    buildkite-cli

    # Network utilities
    dig
    gping

    # Cross-project packages

    # This version isn't working atm.
    # unstable_pkgs.amp-cli
    devbox
    just
    unstable_pkgs.mise

    # LLM CLI tools
    llm_agents.droid

    # Language-specific
    pipenv
    nodejs_24
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
