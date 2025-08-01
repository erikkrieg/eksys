{ pkgs, ... }: with pkgs; {
  imports = [
    ./common-user.nix
  ];

  home.packages = [
    coreutils
    git
    neofetch
    wireguard-tools
    du-dust
    ncdu
    lynis
  ];

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
