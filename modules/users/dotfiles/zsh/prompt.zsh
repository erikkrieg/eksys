setopt PROMPT_SUBST

function prompt_git() {
  info="$(git branch --show-current 2>/dev/null)"
  if [ ! -z "${info}" ]; then
    # Appended empty space
    echo "${info} "
  fi
}

typeset -A SPRING_COLOR=([vi]=84 [dir]=39 [git]=240 [caret]=201)
typeset -A FALL_COLOR=([vi]=214 [dir]=194 [git]=133 [caret]=166)
typeset -A C
set -A C ${(kv)SPRING_COLOR}

P_VIM_MODE='%F{$C[vi]}${ZVM_MODE}%f '
P_DIR='%F{$C[dir]}%1~%f '
P_GIT='%F{$C[git]}$(prompt_git)%f'
P_CARET='%F{$C[caret]}❯%f '

PROMPT="${P_VIM_MODE}${P_DIR}${P_GIT}${P_CARET}"

