# ~/.bashrc: executed by bash(1) for non-login shells.

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
# Fix: Ensure standard local bin is included
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
# DYNAMIC PROMPT
############################################

# Bash terminal prompt session
export PS1='\[\e[38;5;216m\] ➤  \[\e[0m\]'

# Make the terminal change colors
update_dynamic_prompt() {
 local EXIT_CODE=$?

 local RED="\[\e[38;5;196m\]"
 local GREEN="\[\e[38;5;84m\]"
 local YELLOW="\[\e[0;33m\]"
 local BLUE="\[\e[0;34m\]"
 local MAGENTA="\[\e[0;35m\]"
 local CYAN="\[\e[0;36m\]"
 local NC="\[\e[0m\]"

 local PALETTE=("$RED" "$YELLOW" "$GREEN" "$CYAN" "$BLUE" "$MAGENTA")
 # Fix: Ensure arithmetic evaluation is robust
 local idx=$(($(date +%-S) % ${#PALETTE[@]}))
 local COLOR="${PALETTE[$idx]}"

 if [[ "$EXIT_CODE" -eq 0 ]]; then
  PS1="${GREEN} ➤  ${NC}"
 else
  PS1="${RED} ➤💥  ${NC}"
 fi
}

export PROMPT_COMMAND=update_dynamic_prompt

# -----------------------------------------------------------
# SOUND CONFIGURATION
# -----------------------------------------------------------

# Opening Sound
if [ "$PS1" ]; then
 {
  if [[ -f "/opt/audio/info.mp3" ]] && command -v mpv >/dev/null; then
   nohup mpv --no-video /opt/audio/info.mp3 >/dev/null 2>&1 &
   disown
   # else
   # echo -e "(i) No audio files found or mpv missing"
  fi
 } || {
  echo -e " (!) Failure playing sound"
 }
fi

# Closing Sound
# tag:sound,exit
function exit_sound {
 if [[ -f "/opt/audio/twirp.mp3" ]] && command -v mpv >/dev/null; then
  nohup mpv --no-video /opt/audio/twirp.mp3 >/dev/null 2>&1 &
  disown
 fi
}

# Trap the EXIT signal
# Warning: This plays on every shell exit (including subshells).
trap exit_sound EXIT

# -----------------------------------------------------------

################################################
# ALIASES                                      #
################################################

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
 test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
 alias ls='ls --color=auto'
 alias dir='dir --color=auto'
 alias vdir='vdir --color=auto'
 alias grep='grep --color=auto'
 alias fgrep='fgrep --color=auto'
 alias egrep='egrep --color=auto'
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# system tool aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# dev tool alias
alias figfonts='showfigfonts'
alias bat='batcat' # specific to Ubuntu, standard is 'bat' elsewhere
alias tf='terraform'

# Project Navigation
cnc_path="$HOME/Projects/dev.environment"
if [[ -d "$cnc_path" ]]; then
 alias denv="cd $cnc_path"
else
 # Only echo warning if interactive
 if [[ $- == *i* ]]; then
  echo "Setup your CNC project to initialize properly: $cnc_path missing."
 fi
fi

# kubernetes aliases
alias k='kubectl'
# Fix: Removed --headless. k9s is a UI tool; headless renders it useless for interactive sessions.
alias k9s='k9s'
alias kubectl="kubecolor"
alias pods="kubectl get pods -A"
alias deploys="kubectl get deploys -A"
alias svcs="kubectl get svc -A"
# Fix: Increased watch interval from .05 (DoS risk) to 1.0 second
alias wpods="watch -n 1 'kubectl get pods -A'"
alias wdeploys="watch -n 1 'kubectl get deploy -A'"
alias wsvcs="watch -n 1 'kubectl get svc -A'"
alias ctx="kubectl config current-context"
alias ctxs="kubectl config get-contexts"
alias set-ctx='kubectl config use-context'

# Add an "alert" alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# if alias bash resource exists use it
if [ -f ~/.bash_aliases ]; then
 . ~/.bash_aliases
fi

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
# SYSTEM FUNCTIONS                             #
################################################

# House cleaning
function clean {
 sudo apt clean
 sudo apt autoclean
 sudo apt remove -y
 sudo apt autoremove -y
 echo -e "\e[1;92mCleanup Complete\e[0m\n"
}
export -f clean

# Function to update & clean up after
function update {
 sudo apt-get update
 sudo apt update && sudo apt upgrade -y
 echo -e "\e[1;92mUpdate Complete!\e[0m"
 clean
}
export -f update

# Overrides (Requires 'grc' installed)
if command -v grc >/dev/null; then
 function netstat { grc sudo netstat "$@"; }
 function diff { grc diff "$@"; }
 function ping { grc ping "$@"; }
 function head { grc head "$@"; }
 function tail { grc tail "$@"; }
 function mount { grc mount "$@"; }
 function ps { grc sudo ps "$@"; }
fi

# tag:fx,bash,shell,format
function format-bash {
 local input="$1"
 if [[ ! -e "$input" ]]; then
  echo "Bash script not found"
  return 1
 fi
 if command -v shfmt >/dev/null; then
  shfmt -i 1 -w "$input"
  echo -e " \e[2;36mScript\e[0m \e[1;27m$input\e[0m \e[2;36mformatted!\e[0m"
 else
  echo "shfmt not installed."
 fi
}
export -f format-bash

# tag:fx,json,text
function prettyJson {
 local input="$1"
 if [[ -f "$input" ]]; then
  cat "$input" | jq -C . | less -R
 else
  echo "$input" | jq '.'
 fi
}
export -f prettyJson

# tag:fx,spinner
function spin {
 local message="$1"
 local delay=0.2
 local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
 local i=0
 while true; do
  printf "\r%s \033[36m%s\033[0m" "$message" "${spinner:$((i++ % ${#spinner})):1}"
  sleep "$delay"
 done
}
export -f spin

# tag:fx,mp3,audio
function play {
 if [[ -f "$1" ]]; then
  mpv --no-video "$1"
 elif [[ -d "$1" ]]; then
  media_files=()
  while IFS= read -r file; do
   media_files+=("$file")
  done < <(find "$1" -type f -iname "*.mp3")

  if [[ "${#media_files[@]}" -ne 0 ]]; then
   echo "Found ${#media_files[@]} MP3s"
   mpv "${media_files[@]}"
  fi
 else
  echo "Usage : play <filePath|dirPath>"
 fi
}
export -f play

function mp3 { play "$@"; }
export -f mp3

function search {
 local selected_line=$(rg --color=always \
  --line-number \
  --no-heading "$1" |
  fzf --ansi \
   --delimiter=: --nth=1,3.. \
   --preview 'bat --style=numbers --color=always {1} --highlight-line {2} || cat {1}')

 local file_path=$(echo "$selected_line" | cut -d: -f1)

 if [[ -n "$file_path" ]]; then
  echo "Selected file : $file_path"
  vim "$file_path"
 fi
}
export -f search

# Fuzzy file search
# tag:fx,search
function fz {
 local selected_file="$(fzf "$@")"

 if [[ -n "$selected_file" ]]; then
  # Fix: Do not escape here. It breaks dirname.
  # selected_file=$(printf "%q" "$selected_file")

  local extension="${selected_file##*.}"
  local directory=$(dirname "$selected_file")

  # Check system tools
  local editor="vim"
  [[ -x /usr/bin/gedit ]] && editor="gedit"

  OPTION=$(whiptail \
   --title "Fuzzy Search" \
   --menu "Choose an option:" \
   15 50 5 \
   "0" "Open Directory" \
   "1" "View File Contents" \
   "2" "Edit with VIM" \
   "3" "Open with system" \
   "4" "CD to directory" \
   "5" "Exit" \
   3>&1 1>&2 2>&3)

  if [ "$OPTION" == "0" ]; then
   # Fix: 'open' is macOS. Use xdg-open for Linux
   xdg-open "$directory" >/dev/null 2>&1
  elif [ "$OPTION" == "1" ]; then
   bat "$selected_file"
  elif [ "$OPTION" == "2" ]; then
   sudo vim "$selected_file"
  elif [ "$OPTION" == "3" ]; then
   if [[ "$extension" == "mp3" ]]; then
    echo "Listening to : $selected_file"
    mpv --no-video "$selected_file" >/dev/null 2>&1
   else
    # Fallback to system default
    xdg-open "$selected_file" >/dev/null 2>&1
   fi
  elif [ "$OPTION" == "4" ]; then
   echo
   echo -e "Changing directory [\e[1;92m$directory\e[0m]"
   cd "$directory"
   ls -alt "$directory"
   echo
  else
   return
  fi
  echo -e "\e[3;90mSelected File: \e[3;92m$selected_file\e[0m"
 fi
}
export -f fz

# copy file contents to clipboard
# tag:fx,system,txt
function clipboard {
 if [[ -f "$1" ]]; then
  xclip -selection clipboard <"$1"
  filename=$(basename "$1")
  echo -e "\e[3;90m -> File \e[1;92m$filename\e[0m \e[3;90mcontents copied to system clipboard\e[0m"
 else
  echo "File not found."
 fi
}

# tag:fx,discovery
function fx {
 local filter="$1"
 local source_file="$HOME/.bashrc"

 echo
 echo "-------------------------------------------------------"
 echo -e " \e[1;97m(i)\e[0m \e[2;94mAvailable functions \e[0m[\e[1;93m$source_file\e[0m]"
 if [[ -n "$filter" ]]; then
  echo -e " \e[1;97m(i)\e[0m \e[2;94mFilter By Type \e[0m[\e[1;93m$filter\e[0m]"
 fi
 echo "------------------------------------------------------"

 awk -v search="$filter" '
        /^#@?tag:/ {
            sub(/^#@?tag:/, "");
            current_tags = $0; 
            next;
        }
        /^function / || /^[a-zA-Z0-9_]+\(\)/ {
            func_name = "";
            if ($1 == "function") {
                func_name = $2;
            } else {
                split($1, parts, "(");
                func_name = parts[1];
            }
            if (search == "" || index(current_tags, search)) {
                printf "\033[1;92m%s\033[0m\n", func_name;
            }
            current_tags = "";
        }
    ' "$source_file"

 echo "-------------------------------------------------------"
 echo
}

# @tag:fx,syntax,color
function showfx {
 if declare -F "$1" >/dev/null; then
  declare -f "$1" | bat -l bash --file-name "$1"
 else
  echo "Function [$1] not found."
  echo " Usage : showfx <script-function-name>"
 fi
}

################################################
# AWS FUNCTIONS                                #
################################################

# @tag:fx,aws
function cpdeploy {
 if [[ "$#" -ne 2 ]]; then
  echo "usage : cpdeploy <deploy-name> <namespace>"
  return 1
 fi
 kubectl get deploy "$1" -n "$2" -o yaml >"$1.yaml"
 echo -e "Deployment saved: \e[1;92m$PWD/$1.yaml\e[0m"
}
export -f cpdeploy

# tag:fx,aws
function setk8s {
 local region="us-east-1"
 local clusterName

 # Check if AWS CLI works
 if ! command -v aws &>/dev/null; then
  echo "AWS CLI not found."
  return 1
 fi

 clusterName=$(aws eks list-clusters --region "$region" | jq -r '.clusters[0]')

 if [[ "$clusterName" == "null" ]] || [[ -z "$clusterName" ]]; then
  echo -e "\e[1;33m No clusters are present :: Run terraform to setup\e[0m"
  return 1
 fi

 echo -e "Setting Kube config for region [\e[1;92m$region\e[0m] and cluster [\e[1;92m$clusterName\e[0m]"

 if aws eks update-kubeconfig --region "$region" --name "$clusterName"; then
  echo -e " -> \e[92mKube config is now set for AWS\e[0m"
 else
  echo -e " (!) \e[1;91mkube config failed setting for AWS\e[0m"
 fi
 echo
}

# tag:fx,aws
function awskeys {
 echo "Getting caller identity"
 aws sts get-caller-identity --query Account --output text
 echo
 echo "Getting access-key info"
 aws sts get-access-key-info
 echo
 echo "Listing access-keys"
 aws iam list-access-keys
}

# -------------------------------------------------------------
# SECURITY WARNING: DO NOT HARDCODE TOKENS HERE.
# Use an environment variable set in .bash_profile or a secret manager.
# -------------------------------------------------------------
export GIT_TOKEN="${GIT_TOKEN:-PLACEHOLDER_TOKEN_DO_NOT_HARDCODE}"

# tag:fx,aws
function gitlogin {
 curl --request GET \
  --url "https://api.github.com/octocat" \
  --header "Authorization: Bearer $GIT_TOKEN" \
  --header "X-GitHub-Api-Version: 2022-11-28"
}
export -f gitlogin

# tag:fx,aws
function awsuser {
 local username
 username=$(aws iam get-user --query 'User.UserName' --output text 2>/dev/null)

 if [[ $? -ne 0 ]]; then
  echo "Unable to retrieve user. Are you logged in?" >&2
  aws login
  aws sts get-caller-identity
 elif [[ "$username" =~ "None" ]]; then
  echo "root"
 else
  echo "$username"
 fi
}
export -f awsuser

function qr-code {
 if [[ -z "$1" ]]; then
  read -p "Text to convert : " text
 else
  text="$1"
 fi

 local export_filename=""
 local export_dir=""
 local file_ext=".png"

 read -e -r -p "Save location (path/to/file): " export_path

 # Fix: Handle directory vs filename logic
 if [[ -d "$export_path" ]]; then
  export_dir="${export_path%/}" # remove trailing slash
  export_filename="qr_code"
 else
  export_dir=$(dirname "$export_path")
  export_filename=$(basename "$export_path")
 fi

 # Fix: Typo UFT8 -> UTF8, added missing slash in path
 echo "Saving to ${export_dir}/${export_filename}-1${file_ext}..."
 qrencode -m 2 -s 1 -o "${export_dir}/${export_filename}-1${file_ext}" "$text"

 echo "Generating terminal preview..."
 qrencode -m 2 -s 1 -t UTF8 -l L "$text"

 # Second variation
 qrencode -m 2 -s 1 -t UTF8 --foreground="3599FE" --background="FFFFFF" -o "${export_dir}/${export_filename}-2${file_ext}" -l L "$text"
 echo "Saved QR file 2"

 # Terminal preview 2
 qrencode -m 2 -s 1 --foreground="3599FE" --background="FFFFFF" -t UTF8 -l L "$text"
 echo
}
export -f qr-code

function image-to-asci {
 if [[ -f "$1" ]]; then
  jp2a -i --chars="XxxVO" "$1"
 else
  echo "File not found [$1]"
 fi
}
export -f image-to-asci

function convert-image {
 if [[ -f "$1" ]]; then
  # Fix: Ensure output argument is passed
  if [[ -z "$2" ]]; then
   echo "Usage: convert-image <input> <output>"
   return 1
  fi
  convert "$1" -quality 100 "$2"
 else
  echo "File not found [$1]"
 fi
}
export -f convert-image
