{ ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "rg --files --hidden --glob '!.git'";
    defaultOptions = [
      "--height=60%"
      "--layout=reverse"
      "--border"
      "--margin=1"
      "--padding=1"
    ];
  };
}
