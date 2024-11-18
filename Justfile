alias b := rebuild

# List available commands.
list:
  @just -l

# Create GitHub SSH keys using web login flow.
auth-git:
  gh auth login -p ssh -w

# Pull latest changes from remote main branch
fetch: 
  git checkout main
  git pull

# Rebuild system
rebuild:
  #!/usr/bin/env bash
  if [ "$(uname)" = "Darwin" ]; then
    darwin-rebuild switch --flake ".#$(hostname -s)"
  elif [ -f "/etc/NIXOS" ]; then
    sudo nixos-rebuild switch --flake ".#$(hostname -s)"
  else
    echo "Unsupported OS: Only NixOS and Darwin are supported"
    exit 1
  fi

# Update version of flake inputs then rebuild the system
update INPUT: && rebuild
  nix flake lock --update-input {{INPUT}} --commit-lock-file

# Update version of nvim then rebuild the system
update-nvim: && rebuild
  just update envim

# Write ISO to USB device. Example: just flash results/iso/nixos... /dev/sdc
flash ISO DEVICE:
  sudo dd if={{ISO}} of={{DEVICE}} bs=4M status=progress conv=fsync
