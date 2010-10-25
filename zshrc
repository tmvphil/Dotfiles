# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob nomatch
unsetopt beep notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/phil/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


# # # # # # # #
# Environment #
# # # # # # # #
export PATH="$PATH:$HOME/bin"
export EDITOR='vim'
export VIMRUNTIME='/usr/share/vim/vim73'
export LESSHISTFILE='/home/phil/.config/less/lesshst'
export MAIL="/home/phil/.mail/INBOX"
export EMAIL="reinhold@uchicago.edu"
export SYSCONF="~/.xmonad/xmonad.hs ~/.vimrc ~/.zshrc ~/.muttrc ~/.config/uzbl/config ~/.Xdefaults"

# # # # # #
# Aliases #
# # # # # # 
if [ -f ~/.config/zsh/zsh_aliases ]; then
    . ~/.config/zsh/zsh_aliases
fi

# # # # # # # # # # # # # # # # 
# Prompt (coolio's zshrc v0.1)#
# # # # # # # # # # # # # # # #                
if [ -f ~/.config/zsh/zsh_prompt ]; then
    . ~/.config/zsh/zsh_prompt
fi
