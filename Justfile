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
update: fetch
  darwin-rebuild switch --flake '.#'

# Update version of nvim then rebuild the system
update-nvim: fetch
  nix flake lock --update-input envim --commit-lock-file 
  darwin-rebuild switch --flake '.#'

