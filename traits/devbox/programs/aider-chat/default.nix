{ pkgs, ... }: with pkgs; {
  home.packages = [
    aider-chat
  ];
  home.sessionVariables = {
    AIDER_VIM = "true";
    AIDER_SUBTREE_ONLY = "true";
    AIDER_AUTO_COMMITS = "false";
    AIDER_ANALYTIC = "false";
    AIDER_ANALYTICS_DISABLE = "true";
    AIDER_CHECK_UPDATE = "false";
  };
  programs.zsh.shellAliases = {
    gaider = "aider --model groq/deepseek-r1-distill-llama-70b";
  };
}
