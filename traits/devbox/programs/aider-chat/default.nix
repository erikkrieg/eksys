{ unstable_pkgs, ... }: with unstable_pkgs; {
  home.packages = [
    aider-chat
  ];
  home.sessionVariables = {
    AIDER_ANALYTIC = "false";
    AIDER_ANALYTICS_DISABLE = "true";
    AIDER_ATTRIBUTE_AUTHO = "false";
    AIDER_AUTO_COMMITS = "false";
    AIDER_CHECK_UPDATE = "false";
    AIDER_EDITOR = "nvim";
    AIDER_SHOW_DIFFS = "true";
    AIDER_SUBTREE_ONLY = "true";
    AIDER_VIM = "true";
  };
  programs.zsh.shellAliases = {
    gaider = "aider --model groq/deepseek-r1-distill-llama-70b";
  };
}
