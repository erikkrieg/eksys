{ pkgs, unstable_pkgs, ... }: with pkgs; {
  home.packages = [
    k9s
    kubectl
    kubernetes-helm
    unstable_pkgs.kustomize
  ];

  home.sessionVariables = {
    KUBECTL_EXTERNAL_DIFF = "${delta}/bin/delta";
  };

  programs.zsh.shellAliases = {
    k = "kubectl";
  };
}
