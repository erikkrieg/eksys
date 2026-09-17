{
  # Signed llm-agents builds; prefer cache.nixos.org (priority 40) when available.
  # https://github.com/numtide/llm-agents.nix#binary-cache
  # extra-* also preserves existing caches in Determinate and single-user Nix.
  extra-substituters = [ "https://cache.numtide.com?priority=50" ];
  extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  require-sigs = true;
}
