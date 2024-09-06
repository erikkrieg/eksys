{ pkgs, ... }: with pkgs; {
  homebrew = {
    casks = [
      "google-chrome"
      "minikube"
      "tunnelblick"
      "visual-studio-code"
      "raycast"
      "docker-credential-helper-ecr"
    ];
  };

  environment.systemPackages = [
    argocd
  ];

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
}
