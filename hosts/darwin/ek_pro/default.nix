{ ... }: {
  homebrew = {
    casks = [
      "google-chrome"
      "minikube"
      "tunnelblick"
      "visual-studio-code"
      "raycast"
    ];
  };

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
}
