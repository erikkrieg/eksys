{ pkgs, ... }: with pkgs; {
  homebrew = {
    casks = [
      "google-chrome"
      "raycast"
      "chromium"
    ];
  };

  environment.systemPackages = [
    amazon-ecr-credential-helper
    argocd
  ];

  # Changing the binary for sh conflicts with tools like Jamf CLI.
  system.activationScripts.setDashAsSh.enable = false;
}
