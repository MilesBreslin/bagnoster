#!/usr/bin/env bash

if [ "$TERM" != "linux" ]; then
    export _POWERLINE_ARROW=""
    export _POWERLINE_BRANCH=" "                                                # Needs to have space after this
fi

_get_prompt_color() {
    local ERR="$?"
    local path_color=44                                                         # Default Blue
    [ "$(id -u)" == "0" ] && path_color=45                                      # Is Root? Then White
    [ "$ERR" != "0" ] && path_color=41                                          # Command Retuned error? Then Red
    echo "$path_color"
}

_base_prompt() {
    local path_rep='\w'                                                         # Default Let the Shell Handle its own path
    ((COLUMNS < 50)) && path_rep="$(basename "$PWD")"

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null; then       # Is Not Git Directory
        PS1="\[\033[${path_color};30m\] $path_rep \[\033[0;$((path_color-10))m\]$_POWERLINE_ARROW\[\033[0m\] "    # Make it all a string
    else
        local Git_branch="$(basename "$(git symbolic-ref HEAD 2>/dev/null)")"
        local Git_color=43
        [ -z "$(git status -s 2> /dev/null)" ] && Git_color=42                  # Is clean working tree
        PS1="\[\033[${path_color};30m\] $path_rep \[\033[${Git_color};$((path_color-10))m\]$_POWERLINE_ARROW\[\033[${Git_color};30m\] $_POWERLINE_BRANCH$Git_branch \[\033[0;$((Git_color-10))m\]$_POWERLINE_ARROW\[\033[0m\] "    # Make it all a string, relying on \w for directory
    fi
    ((COLUMNS < 50)) && PS1="$PS1"$'\n'
}

_reload_history() {
    history -a
    history -n
}

_pre_newline() {
    PS1=$'\n'"$PS1"
}

_zsh_newline() {
    unset PROMPT_SP                                                             # Detect whether or not the command has a new line ending
    for ((i = 1; i<= $COLUMNS + 52; i++ )); do
        PROMPT_SP+=' ';
    done                                                                        # Credit to Dennis Williamson on serverfault.com
    PS1='\[\e[7m%\e[m\]${PROMPT_SP: -$COLUMNS+1}\015'"$PS1"
}

_pre_hostname() {
    local hostname_color=47
    local hostname="$(</etc/hostname)"
    local hostname="${hostname/.*}"
    PS1="\[\033[${hostname_color};30m\] $hostname \[\033[${path_color};$((hostname_color-10))m\]$_POWERLINE_ARROW$PS1"
}

_prompt() {
    local path_color="$(_get_prompt_color)"
    _base_prompt
    _reload_history
    if [ -n "$SSH_CONNECTION" ] || [ -n "$TMUX" ] || [ -n "$SUDO_COMMAND" ]; then
        _pre_hostname
    fi
    _pre_newline
}

PROMPT_COMMAND=_prompt
