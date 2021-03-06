#! /bin/bash

# General aliases
alias l="ls --color=auto"
alias ll="ls -lh --color=auto"
alias lla="ls -lah --color=auto"
alias pee="pulseaudio-equalizer enable"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rgrep='rgrep --color=auto'
alias week="date +%V"
alias aptgrade="sudo apt-get update && sudo apt-get upgrade"
alias listfunctions="declare -f | egrep '.* \(\) {' | grep -v '_'"

# Mount encrypted dropbox folder
alias mountcrypto="encfs -o allow_root ~/Dropbox/.encrypted ~/Private"

# Show lines that are not commented out
alias active='grep -v -e "^$" -e"^ *#"'

# Show frequent commands
alias freq='cut -f1 -d" " ~/.zsh_history | sort | uniq -c | sort -nr | head -n
30'

# Find a host in $HOME/.aliases 
function getSSHLineFromAliases {
    user=$(sed -n "$1p" $HOME/.aliases | awk '{print $3}')
    if [[ $user == "" ]]; then
        # Line does not exist, return 1
        return 1
    fi 
    type=$(sed -n "$1p" $HOME/.aliases | awk '{print $2}')
    host=$(sed -n "$1p" $HOME/.aliases | awk '{print $4}')
    port=$(sed -n "$1p" $HOME/.aliases | awk '{print $5}')
    if [[ $port == "" ]]; then 
        port="22"
    fi
    if [[ $type == "mosh" ]]; then
        port="2222"
    fi
    echo "$type -p $port $2 $user@$host"
}

function getFieldFromAliases {
    echo `sed -n "$1p" $HOME/.aliases | awk "{print \\$$2}"`
}

if [ -s $HOME/.aliases ]; then
    # Hosts, first line has a comment
    count=0
    while read line; do
        count=$(($count + 1))
        if echo $line | grep -q "#"; then
            # Line has a hash comment, skip
            continue
        fi
        alias `getFieldFromAliases $count 1`="`getSSHLineFromAliases $count`"
    done < $HOME/.aliases

    # IRC
    alias irc="`getSSHLineFromAliases 3` -- tmux att -t irc"

    # WOL
    alias wake_wally="`getSSHLineFromAliases 2` wake wally"
    alias wake_mediabox="`getSSHLineFromAliases 2` wake mediabox"
fi
