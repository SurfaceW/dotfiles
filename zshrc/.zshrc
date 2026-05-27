#  ---------------------------------------------------------------------------
#  ~/.zshrc — sanitized template (managed by ~/dotfiles)
#
#  Convention: this file is the canonical zsh config. Per-machine extras live
#  in ~/.zshrc.local. Secrets live in ~/.secrets/*.env (chmod 600). Both are
#  gitignored and sourced from the tail of this file.
#
#  Maintenance: see ~/.agentic-arno/skills/arno/cio/dotfiles-keeper/SKILL.md
#  ---------------------------------------------------------------------------

echo "🤩 Arno"

#   -------------------------------
#   1.  OH MY ZSH CONFIGURATION
#   -------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="avit"

# Plugins — order matters: zsh-syntax-highlighting MUST be last.
plugins=(
  git
  macos
  autojump
  wd
  copyfile
  history
  last-working-dir
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"


#   -------------------------------
#   2.  PATH & ENVIRONMENT
#   -------------------------------

# Homebrew (Apple Silicon)
[ -d "/opt/homebrew/bin" ] && export PATH="/opt/homebrew/bin:$PATH"

# User-local bins
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"

# Default editor
export EDITOR="vim"

# Default blocksize for ls, df, du
export BLOCKSIZE=1k

# Terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Java (auto-detect; silent if absent)
if /usr/libexec/java_home >/dev/null 2>&1; then
  export JAVA_HOME="$(/usr/libexec/java_home)"
fi


#   -----------------------------
#   3.  MAKE TERMINAL BETTER
#   -----------------------------

alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'
alias ll='ls -FGlAhp'
alias less='less -FSRXc'
cd() { builtin cd "$@" && ls; }
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'
alias f='open -a Finder ./'
alias ~="cd ~"
alias c='clear'
alias path='echo -e ${PATH//:/\\n}'
alias fix_stty='stty sane'
alias cic='set completion-ignore-case On'

# Make new dir and jump in
mcd () { mkdir -p "$1" && cd "$1"; }

# Move file to macOS Trash
trash () { command mv "$@" ~/.Trash; }

# Quicklook preview
ql () { qlmanage -p "$*" >& /dev/null; }

alias DT='tee ~/Desktop/terminalOut.txt'
alias size='du -d 1 -h'

# Search manpage for term, paginated with color
mans () {
  man "$1" | grep -iC2 --color=always "$2" | less
}


#   -------------------------------
#   4.  FILE & FOLDER MANAGEMENT
#   -------------------------------

# Zip a folder
zipf () { zip -r "$1".zip "$1" ; }

alias numFiles='echo $(ls -1 | wc -l)'

# cd to frontmost Finder window
cdf () {
  currFolderPath=$( /usr/bin/osascript <<EOT
    tell application "Finder"
      try
        set currFolder to (folder of the front window as alias)
      on error
        set currFolder to (path to desktop folder as alias)
      end try
      POSIX path of currFolder
    end tell
EOT
  )
  echo "cd to \"$currFolderPath\""
  cd "$currFolderPath"
}

# Extract most known archive types
extract () {
  if [ -f "$1" ] ; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"    ;;
      *.tar.gz)  tar xzf "$1"    ;;
      *.bz2)     bunzip2 "$1"    ;;
      *.rar)     unrar e "$1"    ;;
      *.gz)      gunzip "$1"     ;;
      *.tar)     tar xf "$1"     ;;
      *.tbz2)    tar xjf "$1"    ;;
      *.tgz)     tar xzf "$1"    ;;
      *.zip)     unzip "$1"      ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      7z x "$1"       ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


#   ---------------------------
#   5.  SEARCHING
#   ---------------------------
# Modern alternative: prefer `rg` (ripgrep) and `fd` for new searches.

ff ()  { /usr/bin/find . -name "$@" ; }
ffs () { /usr/bin/find . -name "$@"'*' ; }
ffe () { /usr/bin/find . -name '*'"$@" ; }

spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }


#   ---------------------------
#   6.  PROCESS MANAGEMENT
#   ---------------------------

alias memHogsTop='top -l 1 -o rsize | head -20'
alias memHogsPs='ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpu_hogs='ps wwaxr -o pid,stat,%cpu,time,command | head -10'
alias topForever='top -l 9999999 -s 10 -o cpu'
alias ttop="top -R -F -s 10 -o rsize"

# List my processes
my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command ; }


#   ---------------------------
#   7.  NETWORKING
#   ---------------------------

alias myip='ifconfig | grep inet" "'
alias netCons='lsof -i'
alias flushDNS='dscacheutil -flushcache'
alias lsock='sudo /usr/sbin/lsof -i -P'
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP'
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP'
alias ipInfo0='ipconfig getpacket en0'
alias ipInfo1='ipconfig getpacket en1'
alias openPorts='sudo lsof -i | grep LISTEN'
alias nproc='sysctl -n hw.physicalcpu'

# Useful host info
ii() {
  echo -e "\nYou are logged on ${RED}$HOST"
  echo -e "\nAdditional information:$NC " ; uname -a
  echo -e "\n${RED}Users logged on:$NC "    ; w -h
  echo -e "\n${RED}Current date :$NC "      ; date
  echo -e "\n${RED}Machine stats :$NC "     ; uptime
  echo -e "\n${RED}Network location :$NC "  ; scselect
  echo -e "\n${RED}Public IP :$NC "         ; myip
  echo
}


#   ---------------------------------------
#   8.  SYSTEMS OPERATIONS & INFORMATION
#   ---------------------------------------

alias mountReadWrite='/sbin/mount -uw /'
alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
alias finderShowHidden='defaults write com.apple.finder ShowAllFiles TRUE'
alias finderHideHidden='defaults write com.apple.finder ShowAllFiles FALSE'


#   ---------------------------------------
#   9.  ALIASES — GIT, LANGUAGES, TOOLS
#   ---------------------------------------

# Git
alias co='git checkout'
alias br='git branch'
alias ci='git cz'
alias gs='git status'
alias gpl='git pull'
alias gps='git push origin'
alias diff='git diff'
alias rebase='git rebase'
alias reset='git reset'
alias merge='git merge'
alias stree='open . -a SourceTree'

# Python
alias p='python3'
alias pip='pip3'

# Kubernetes
alias k8s='kubectl'


#   ---------------------------------------
#   10. TOOL INITIALIZERS
#   ---------------------------------------

# autojump
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && \
  source /opt/homebrew/etc/profile.d/autojump.sh

# NVM (lazy-loaded; avoids ~250ms startup cost)
export NVM_DIR="$HOME/.nvm"
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  nvm() {
    unset -f nvm node npm npx
    source "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \
      source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
    nvm "$@"
  }
  node() { unset -f node; nvm use default >/dev/null 2>&1; node "$@"; }
  npm()  { unset -f npm;  nvm use default >/dev/null 2>&1; npm "$@"; }
  npx()  { unset -f npx;  nvm use default >/dev/null 2>&1; npx "$@"; }
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"


#   ---------------------------------------
#   11. SECRETS & MACHINE-LOCAL OVERRIDES
#   ---------------------------------------
#  Keep this section LAST so per-machine values can override everything above.

# Secrets — gitignored, chmod 600. Examples: keys.env, work.env, proxy.env.
if [ -d "$HOME/.secrets" ]; then
  for f in "$HOME"/.secrets/*.env; do
    [ -r "$f" ] && source "$f"
  done
fi

# Machine-local overrides — paths, employer-specific aliases, scratch exports.
[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# Ensure sourcing this file always returns 0.
true
