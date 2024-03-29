# Configure Darwin system space.
# https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ config, pkgs, ... }: with pkgs; {
  imports = [ ./common-host.nix ];

  # Backwards compatibility. Don't change.
  system.stateVersion = 4;

  # Configure default login shell (nix-darwin exclusive option).
  environment.loginShell = zsh;

  # There may be a more nixy way to do this with nix-darwin, but using 
  # activationScripts to optionally:
  # 1. Make zsh default shell for root user
  # 2. Use dash binary as sh instead of bash
  system.activationScripts.postActivation.text = with config.system.activationScripts; ''
    ${ if setZshAsDefaultRootShell.enable then setZshAsDefaultRootShell.text else "" }
    ${ if setDashAsSh.enable then setDashAsSh.text else "" }
  '';

  # Use zsh managed by nix as the default root shell instead of bash binary
  # managed by the OS.
  # There might be a nix-darwin setting I can use in place of this. Need to 
  # look into that.
  system.activationScripts.setZshAsDefaultRootShell.text = ''
    echo "set zsh as default shell for root..."
    NIX_SYS="/run/current-system/sw"
    ZSH="$NIX_SYS/bin/zsh"
    if [ "$SHELL" != "$ZSH" ]; then
      echo "  - using zsh as default shell for root"
      chsh -s "$ZSH" "$USER"
    fi
  '';

  # Set sh to execute dash because it is faster than bash
  # Important: dash is limited to the posix specification, so has fewer 
  # features than bash, which is a superset of posix.
  system.activationScripts.setDashAsSh.text = ''
    echo "set dash as sh..."
    DASH="/bin/dash"
    if [ "$(readlink /var/select/sh)" != "$DASH" ]; then
      echo "  - linking sh to dash because it is a faster shell"
      ln -sf "$DASH" /var/select/sh
    fi
  '';

  services.nix-daemon.enable = true; # Allow nix-darwin to manages/updates the daemon

  # Configure keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  environment.systemPackages = [
    wireguard-go
  ];

  services = {
    tailscale = {
      enable = true;
      # Set nameserver to 100.100.100.100
      # Should be done on a per host basis because this breaks DNS if that host
      # hasn't been added to the tailnet yet.
      # overrideLocalDns = true;
    };
  };

  networking = lib.mkIf config.services.tailscale.overrideLocalDns {
    knownNetworkServices = [
      "Wi-Fi"
      "Ethernet Adaptor"
      "Thunderbolt Ethernet"
    ];
  };
}
