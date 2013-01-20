# Use modern completion system
autoload -Uz compinit
compinit

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Do not repeat history of unique commands
setopt HIST_IGNORE_ALL_DUPS

# Don't log my spaces!
# Start a command with a space, it won't get logged!
setopt histignorespace

# Change directories without cd
setopt autocd

# Trying something simpler
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Adds slashes to dots! \o/
# When cding, try entering cd .... 
function rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/../
    else
        LBUFFER+=.
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

# Spelling correction
setopt correct

# Host completion
# Will autocomplete hosts with SSH, rsync and scp
if [ -f ~/.hosts ]; then
    zstyle ':completion:*:(ssh|rsync|scp):*' hosts "${(f)$(awk '{print $2}' <~/.hosts)}"
fi

# Enable cache for completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

setopt extended_glob

# Some environmental/shell pref stuff
setopt EXTENDED_HISTORY # puts timestamps in the history
setopt ALL_EXPORT

# Colors
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done

# Add toolkit dir to path, if it exists
if [ -d ~/git/toolkit ]; then
    PATH="$PATH:~/git/toolkit"
fi

# Prompt
PR_NO_COLOR="%{$terminfo[sgr0]%}"
PS1="$PR_BLUE%n$PR_WHITE@$PR_GREEN%m%u$PR_NO_COLOR:$PR_RED%2c$PR_NO_COLOR%(!.#.$) "

# For macbook
if which battery &> /dev/null; then
    if [[ ! `battery` == "" ]]; then
        RPROMPT="$PR_NO_COLOR%D{[%H:%M} -$(battery)$PR_NO_COLOR]$PR_NO_COLOR"
    else 
        RPROMPT="$PR_LIGHT_WHITE%D{[%H:%M]}$PR_NO_COLOR"
    fi
fi

# Fix home, end and delete
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char

# Allow comments interactive shell
setopt interactivecomments

# Set editor to vim
if [[ -x /usr/bin/vim ]]; then
    export EDITOR='vim'
fi

# Load aliases
if [[ -s ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

# Suggest package for command not found
if [[ -s /etc/zsh_command_not_found ]]; then
    . /etc/zsh_command_not_found
fi

# Download zsh-syntax-highlighting
if [ ! -f ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    echo "Could not find zsh-syntax-highlighting, downloading.."
    git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-syntax-highlighting &> /dev/null
fi
source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Source bash_functions
if [ ! -L ~/.bash_functions ]; then
    source ~/.bash_functions
fi

# Set 256 colors
export TERM="xterm-256color"
# If session is tmux, set screen-256color
[ -n "$TMUX" ] && export TERM=screen-256color

# Bind ^r for backwards search
bindkey '^R' history-incremental-search-backward
