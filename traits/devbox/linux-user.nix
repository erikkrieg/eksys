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

  # Nix settings that can be managed per-user
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };
}
