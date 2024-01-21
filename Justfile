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
  darwin-rebuild switch --flake ".#$(hostname -s)"

# Update version of flake inputs then rebuild the system
update INPUT: && rebuild
  nix flake lock --update-input {{INPUT}} --commit-lock-file

# Update version of nvim then rebuild the system
update-nvim: && rebuild
  just update envim

