{
  description = "Minimal NixOS installation media";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      exampleIso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            users.users.nixos.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOjh1wU4Pqef3+Buo/nFgsdQlbLaRAiz7L6tX+n3fJ74 ek@eksys"
            ];
            services.openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };
            };
          })
        ];
      };
    };
  };
}
