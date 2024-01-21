{ lib, ... }: {
  # exa was replaced by eza, a more active fork
  programs.eza = {
    enable = true;
  };
  programs.zsh.shellAliases = {
    ls = "eza --group-directories-first";
    l = lib.mkForce "eza --group-directories-first -la --git";
    tree = "eza --group-directories-first --tree -a -I='.git'";
    tree2 = "tree --level=2";
    tree3 = "tree --level=3";
    tree4 = "tree --level=4";
  };
}
