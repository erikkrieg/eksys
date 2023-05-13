{ pkgs, ... }: with pkgs; {
  home.packages = [
    kubectl
    kubernetes-helm
    k9s
  ];

  programs.zsh.shellAliases = {
    k = "kubectl";
  };
}
