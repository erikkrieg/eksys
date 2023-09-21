{ pkgs, ... }: with pkgs; {
  homebrew = {
    casks = [
      "google-chrome"
      "raycast"
    ];
  };

  environment.systemPackages = [
    argocd
  ];

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
}
