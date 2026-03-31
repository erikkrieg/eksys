{ pkgs, unstable_pkgs, ... }: with pkgs; {
  home.packages = [
    kubectl
    kubectx
    kubernetes-helm
    stern
    unstable_pkgs.k9s
    unstable_pkgs.kustomize
  ];

  home.sessionVariables = {
    KUBECTL_EXTERNAL_DIFF = "${delta}/bin/delta";
  };

  programs.zsh.shellAliases = {
    k = "${kubectl}/bin/kubectl";
    kx = "${kubectx}/bin/kubectx";
  };
}
