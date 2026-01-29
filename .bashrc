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

############################################
# TERMINAL FUNCTIONS
############################################

# Pre-calculate colors once to speed up prompt rendering
_DYN_RED="\[\e[38;5;196m\]"
_DYN_GREEN="\[\e[38;5;84m\]"
_DYN_YELLOW="\[\e[0;33m\]"
_DYN_BLUE="\[\e[0;34m\]"
_DYN_MAGENTA="\[\e[0;35m\]"
_DYN_CYAN="\[\e[0;36m\]"
_DYN_NC="\[\e[0m\]"
_DYN_PALETTE=("$_DYN_RED" "$_DYN_YELLOW" "$_DYN_GREEN" "$_DYN_CYAN" "$_DYN_BLUE" "$_DYN_MAGENTA")

update_dynamic_prompt() {
 local EXIT_CODE=$?
 local idx=$(($(date +%-S) % ${#_DYN_PALETTE[@]}))

 # Note: The random color logic is applied to the prompt symbol,
 # but distinct Green/Red is used for success/fail.

 if [[ "$EXIT_CODE" -eq 0 ]]; then
  PS1="${_DYN_GREEN} ➤  ${_DYN_NC}"
 else
  PS1="${_DYN_RED} ➤💥  ${_DYN_NC}"
 fi
}

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

# Warning: This plays on every shell exit (including subshells).
trap exit_sound EXIT
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
 source /home/xxx/dev.environment/.bash_packages
 source /home/xxx/dev.environment/.bash_aliases
 source /home/xxx/dev.environment/.bash_functions
 source /home/xxx/dev.environment/.bash_completions
