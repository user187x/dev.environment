# ~/.bashrc:

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# --- History Control ---
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
export LESSHISTFILE=/dev/null

# --- Path Configuration ---
if [ -d "$HOME/.local/bin" ]; then
 export PATH="$HOME/.local/bin:$PATH"
fi

# Check the window size after each command
shopt -s checkwinsize

################################################
# Shell Instantiation                          #
################################################

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
 debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in xterm-color | *-256color)
 color_prompt=yes
 ;;
esac

if [ -n "$force_color_prompt" ]; then
 if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  color_prompt=yes
 else
  color_prompt=
 fi
fi

# Customization to shell prompt fallback
case "$TERM" in
xterm* | rxvt*)
 PS1=' \[\e[1;92m\]\u\[\e[0m\] [\[\e[1;90m\]\W\[\e[0m\]] '
 ;;
*) ;;
esac

#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

################################################
# LOAD CUSTOM DEFINITIONS                      #
################################################

# Source Functions
if [ -f ~/.bashrc_functions ]; then
 . ~/.bashrc_functions
fi

# Source Aliases
if [ -f ~/.bashrc_aliases ]; then
 . ~/.bashrc_aliases
fi

############################################
# DYNAMIC PROMPT & ENV EXECUTION
############################################

# Bash terminal prompt session
export PS1='\[\e[38;5;216m\] ➤  \[\e[0m\]'

# Execute the dynamic prompt update (Function defined in bashrc_functions)
export PROMPT_COMMAND=update_dynamic_prompt

################################################
# BASH AUTO COMPLETE                           #
################################################

# Kubectl auto-complete
if command -v kubectl >/dev/null; then
 source <(kubectl completion bash)
 complete -o default -F __start_kubectl k
fi

if ! shopt -oq posix; then
 if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
 elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
 fi
fi

################################################
# CONFIGURATION & HOOKS                        #
################################################

# Sound Configuration - Opening Sound
if [ "$PS1" ]; then
 {
  if [[ -f "/opt/audio/info.mp3" ]] && command -v mpv >/dev/null; then
   nohup mpv --no-video /opt/audio/info.mp3 >/dev/null 2>&1 &
   disown
  fi
 } || {
  echo -e " (!) Failure playing sound"
 }
fi

# Trap the EXIT signal
# Warning: This plays on every shell exit (including subshells).
trap exit_sound EXIT

# -------------------------------------------------------------
# Use an environment variable set in .bash_profile or a secret manager.
# -------------------------------------------------------------
export GIT_TOKEN="${GIT_TOKEN:-PLACEHOLDER_TOKEN_DO_NOT_HARDCODE}"
