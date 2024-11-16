{ pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjh1wU4Pqef3+Buo/nFgsdQlbLaRAiz7L6tX+n3fJ74 ek@eksys"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxcsEfj6Tnq8qJt3WFLYM4EwBYWwL4mr458vNVqDn1W ek@june"
  ];
  services.openssh.enable = true;
}
