{ pkgs, ... }: {
  homebrew = {
    casks = [ ];
  };

  environment.systemPackages = with pkgs; [
    fluxcd
  ];

  # Changing the binary for sh can conflict with IT tools
  system.activationScripts.setDashAsSh.enable = false;
}
