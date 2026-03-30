#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

export PS1='[$?] \[\e[92;1m\]\u\[\e[0m\]@\[\e[96;1;2m\]\h\[\e[0m\]:\w \[\e[94;1m\]λ\[\e[0m\] '
export MOZ_ENABLE_WAYLAND=1
