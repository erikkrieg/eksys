{ nixpkgs, unstable, disko, home-manager, envim, ... }@args:
let
  mkHost = { system, user, traits, modules ? [ ] }: (nixpkgs.lib.nixosSystem) {
    pkgs = import nixpkgs { inherit system; };
    modules = modules ++ [
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            envim = envim.packages.${system}.default;
            unstable_pkgs = import unstable { inherit system; };
          };
          users.${user}.imports = map (trait: ../../traits/${trait}/nixos-user.nix) traits;
        };
      }
    ] ++ map (trait: ../../traits/${trait}/nixos-host.nix) traits;
  };
in
{
  june = mkHost {
    system = "x86_64-linux";
    user = "ek";
    traits = [ "devbox" "server" "dns" ];
    modules = [ ./june ];
  };

  noosh = mkHost {
    system = "x86_64-linux";
    user = "ek";
    traits = [ "devbox" "server" ];
    modules = [ ./noosh ];
  };

  chips = mkHost {
    system = "x86_64-linux";
    user = "ek";
    traits = [ "devbox" "server" ];
    modules = [ disko.nixosModules.disko ./chips ];
  };

  # NixOS can be installed on a new host with an output like this. I'm keeping
  # this around for now until I figure out how to fold this into the "final" config.
  new_host = nixpkgs.lib.nixosSystem {
    # nixos-anywhere only works with intel chips atm
    system = "x86_64-linux";
    specialArgs = args;
    modules = [
      ({ modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          disko.nixosModules.disko
          (import ./disks.nix { disks = [ "/dev/sda" ]; })
        ];
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        services.openssh.enable = true;
        # Current config doesn't create any passwords so SSH is the only way to manage the host
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxcsEfj6Tnq8qJt3WFLYM4EwBYWwL4mr458vNVqDn1W ek@june"
        ];
      })
    ];
  };
}
