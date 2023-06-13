{ ... }: {
  homebrew = {
    casks = [
      "google-chrome"
      "minikube"
      "slack"
      "tunnelblick"
      "visual-studio-code"
    ];
  };

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
}
