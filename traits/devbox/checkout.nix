# Where each host keeps its git checkout of this repo. Home files that must
# stay writable link into it instead of the Nix store.
{ config, lib, ... }: {
  options.eksys.checkout = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/dev/erikkrieg/eksys";
    description = "Path to this host's eksys checkout.";
  };
}
