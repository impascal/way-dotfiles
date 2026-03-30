#
# ~/.bash_profile
#

[[ "$(tty)" = "/dev/tty1" ]] && exec sway
[[ -f ~/.bashrc ]] && . ~/.bashrc
