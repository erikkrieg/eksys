{ lib, ... }: {
  programs.exa = {
    enable = true;
  };
  programs.zsh.shellAliases = {
    ls = "exa --group-directories-first";
    l = lib.mkForce "exa --group-directories-first -la --git";
    tree="exa --tree -a -I='.git'";
    tree2="tree --level=2";
    tree3="tree --level=3";
    tree4="tree --level=4";
  };
}
