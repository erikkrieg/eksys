{ ... }: {
  homebrew = {
    casks = [ ];
  };

  environment.systemPackages = [ ];

  # Changing the binary for sh can conflict with IT tools
  system.activationScripts.setDashAsSh.enable = false;
}
