{ pkgs, ... }: with pkgs; {
  home.packages = [
    k9s
    kubectl
    kubernetes-helm
    kustomize
  ];

  programs.zsh.shellAliases = {
    k = "kubectl";
  };
}
