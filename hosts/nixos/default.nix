{ nixpkgs, disko, home-manager, envim, ... }@args:
let
  mkHost = { system, user, traits, modules ? [ ] }: (nixpkgs.lib.nixosSystem) {
    pkgs = import nixpkgs { inherit system; };
    modules = modules ++
      [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              envim = envim.packages.${system}.default;
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
    traits = [ ];
    modules = [ disko.nixosModules.disko ./chips ];
  };

  # chips = nixpkgs.lib.nixosSystem {
  #   system = "x86_64-linux";
  #   specialArgs = args;
  #   modules = [
  #     ({ modulesPath, ... }: {
  #       imports = [
  #         (modulesPath + "/installer/scan/not-detected.nix")
  #         (modulesPath + "/profiles/qemu-guest.nix")
  #         disko.nixosModules.disko
  #         (import ./disks.nix {
  #           disks = [ "/dev/sda" ];
  #         })
  #       ];
  #       boot.loader.systemd-boot.enable = true;
  #       boot.loader.efi.canTouchEfiVariables = true;
  #       services.openssh.enable = true;
  #
  #       users.users.root.openssh.authorizedKeys.keys = [
  #         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxcsEfj6Tnq8qJt3WFLYM4EwBYWwL4mr458vNVqDn1W ek@june"
  #       ];
  #     })
  #   ];
  # };
}
