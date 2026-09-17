# Configure Darwin system space.
# https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ config, pkgs, ... }: with pkgs; {
  imports = [ ./common-host.nix ];

  # Backwards compatibility. Don't change.
  system.stateVersion = 4;

  system.activationScripts.postActivation.text = with config.system.activationScripts; ''
    ${ if setZshAsDefaultRootShell.enable then setZshAsDefaultRootShell.text else "" }
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

  # Configure keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Allow Touch ID (and Apple Watch) to authenticate sudo.
  # Manages /etc/pam.d/sudo_local with `auth sufficient pam_tid.so`.
  security.pam.services.sudo_local.touchIdAuth = true;

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
