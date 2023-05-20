# Zsh

## zsh-vi-mode plugin
Turns out that the zsh-vi-mode plugin doesn't play super well with some other integrations by default. I discovered this that hard way while tryign to figure out why my `fzf` zsh integration was having the history search keybind overwritten. Figuring out the source of this ended up relying on me disabling other integrations and plugins and turning them back on gradually until it was clear that `zsh-vi-mode` was somehow responsible.

Investigating the `zsh-vi-mode` plugin script, I noticed that it appended a function map key bindings into `precmd_functions`, which appears to execute late in the shell invocation, overriding `bindkey -M viins '^r'`.

My first attempt to fix this:

```zsh
# zsh-vi-mode creates a number of bindkeys that get initialized with 
# precmd_functions, which is run before each prompt is displayed. This
# was interfering with a fzf bindkey that I wanted while in insert mode.
function unset_zsh_vi_mode_history_bindkey() {
zvm_bindkey viins '^R' fzf-history-widget
} 
precmd_functions+=(unset_zsh_vi_mode_history_bindkey)
```

Taking a look at the plugin's README I noticed deep in the doc a reference to [issues with other integrations like `fzf`](https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands) and an even later mention of changing the [initialization mode from precmd to at the time of sourcing](https://github.com/jeffreytse/zsh-vi-mode#initialization-mode).

