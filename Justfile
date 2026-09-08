alias b := rebuild
alias bt := rebuild-target

set positional-arguments

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

# Rebuild system, using the remembered target or the matching hostname
rebuild:
  bash ./scripts/nix.sh rebuild

# Rebuild system with specific target name
rebuild-target TARGET:
  bash ./scripts/nix.sh rebuild "$1"

# Update one input, commit the lockfile, then rebuild
update INPUT: && rebuild
  bash ./scripts/nix.sh flake update "$1" --commit-lock-file

# Update nvim and rebuild once
update-nvim:
  just update envim

# Test target selection and update/rebuild behavior, needs python3
test:
  python3 -B -m unittest discover -s tests -p 'test_workflow.py' -v

# Write ISO to USB device. Example: just flash results/iso/nixos... /dev/sdc
flash ISO DEVICE:
  sudo dd if={{ISO}} of={{DEVICE}} bs=4M status=progress conv=fsync
