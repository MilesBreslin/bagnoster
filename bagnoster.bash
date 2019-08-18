#!/usr/bin/env bash

if [ "$TERM" != "linux" ]; then
    export _POWERLINE_ARROW=""
    export _POWERLINE_BRANCH=" "                                                # Needs to have space after this
fi

_prompt() {
    local ERR="$?"
    local path_color=44                                                         # Default Blue
    local path_rep='\w'                                                         # Default Let the Shell Handle its own path
    [ "$ERR" != "0" ] && path_color=41                                          # Command Retuned error? Then Red
    [ "$(id -u)" == "0" ] && path_color=47                                      # Is Root? Then White
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
    history -a
    history -n
}

PROMPT_COMMAND=_prompt
