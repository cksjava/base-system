# Begin /etc/bashrc
# Written for Beyond Linux From Scratch
# by James Robertson 
# updated by Bruce Dubbs 

# System wide aliases and functions.

# System wide environment variables and startup programs should go into
# /etc/profile.  Personal environment variables and startup programs
# should go into ~/.bash_profile.  Personal aliases and functions should
# go into ~/.bashrc

# Provides colored /bin/ls and /bin/grep commands.

if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Provides prompt for interactive shells, specifically shells started
# in the X environment. [Review the LFS archive thread titled
# PS1 Environment Variable for a great case study behind this script
# addendum.]

NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

unset RED GREEN NORMAL

# GnuPG wants this or it'll fail with pinentry-curses under some
# circumstances (for example signing a Git commit)
# Note that tty -s will "succeed" in LFS chroot environment so we cannot
# use -s instead of redirecting to /dev/null.
$(tty &>/dev/null) && export GPG_TTY=$(tty)

# End /etc/bashrc
