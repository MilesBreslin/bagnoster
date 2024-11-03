#!/usr/bin/env bash

if [ "$TERM" != "linux" ]; then
    export _POWERLINE_ARROW=""     # Needs to have space after this
    export _POWERLINE_BRANCH=""
fi

_set_pretty_prompt() {
    unset PS1
    local padding="$1"
    shift
    while [ -n "$1" ] ; do
        local bg_color="$1"
        local primary_color="$2"
        local text="$3"
        local transition_color=0
        [ -n "$4" ] && transition_color="$(("$4"))"
        shift ; shift ; shift
        PS1+="\[\033[${bg_color};${primary_color}m\]${padding}${text}${padding}\[\033[${transition_color};$((bg_color-10))m\]$_POWERLINE_ARROW"
    done
    PS1+="\[\033[0m\]${padding}"
}

_append_to_prompt() {
    PRETTY_PROMPT=("${PRETTY_PROMPT[@]}" "$1" "$2" "$3")
}

_base_prompt() {
    local ERR="${1:-0}"
    local path_color=44                                                     # Default Blue
    [[ "$PATH" =~ ^/nix/store ]] && path_color=46                           # Compressed Nix Store signal
    [ "$(id -u)" == "0" ] && path_color=45                                  # Is Root? Then White
    [ -n "${PROMPT_SET_COLOR//[^0-9]}" ] && path_color="$PROMPT_SET_COLOR"  # Overriden prompt color?
    [ "$ERR" != "0" ] && path_color=41                                      # Command Retuned error? Then Red
    if [ -n "$PROMPT_PATH" ] ; then
        _append_to_prompt "$path_color" 30 "${PWD/"${PROMPT_PATH}"/"${PROMPT_SET_PATH:-!}"}"
    elif ((PROMPT_SIZE==2)) ; then
        _append_to_prompt "$path_color" 30 "\w"
    else
        _append_to_prompt "$path_color" 30 "$(basename "$PWD")"
    fi
}

_git_prompt() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>/dev/null; then     # Is Not Git Directory
        local Git_branch=""
        local branch_symbol="${_POWERLINE_BRANCH}"
        if ((PROMPT_SIZE==2)) ; then
            Git_branch="$(basename "$(git symbolic-ref HEAD 2>/dev/null)")"
            [ -n "${_POWERLINE_BRANCH}" ] && branch_symbol="${_POWERLINE_BRANCH} "
        fi
        local Git_color=43
        [ -z "$(git status -s 2> /dev/null)" ] && Git_color=42              # Is clean working tree
        _append_to_prompt "${Git_color}" 30 "${branch_symbol}${Git_branch}"
    fi
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
    for ((i = 1; i<= $COLUMNS + 52; i++ )); do                                  # Will mangle terminal on resize
        PROMPT_SP+=' ';
    done                                                                        # Credit to Dennis Williamson on serverfault.com
    PS1='\[\e[7m%\e[m\]${PROMPT_SP: -$COLUMNS+1}\015'"$PS1"
}

_pre_hostname() {
    ((PROMPT_SIZE>=2)) || return 0;
    local hostname_color=47
    local hostname
    if [[ -n "${BASH_HOSTNAME:+x}" ]] ; then
        hostname="$BASH_HOSTNAME"
    else
        hostname="$(</proc/sys/kernel/hostname)"
        hostname="${hostname/.*}"
    fi
    _append_to_prompt 47 30 "$hostname"
}

_nix_shell() {
    ((PROMPT_SIZE>=2)) || return 0
    if [[ "$PATH" =~ ^/nix/store ]] ; then
        _append_to_prompt 42 30 "$(<<< "$PATH" sed 's,:.*,,;s,^/nix/store/[a-z0-9]*-,,;s,-.*,,;s,/bin$,,')"
    fi
}

_prompt() {
    local ERR="$?"
    local PRETTY_PROMPT=()

    # Calculate prompt size if not set. Larger number is larger size
    if [ -z "$PROMPT_SIZE" ] ; then
        local PROMPT_SIZE=2
        ((COLUMNS<75)) && PROMPT_SIZE="1"
        ((COLUMNS<50)) && PROMPT_SIZE="0"
    fi

    local padding=" "
    ((PROMPT_SIZE<2)) && padding=""

    _nix_shell
    if [ -n "$SSH_CONNECTION" ] || [ -n "$TMUX" ] || [ -n "$SUDO_COMMAND" ]; then
        _pre_hostname
    fi
    _base_prompt "$ERR"
    _git_prompt
    _set_pretty_prompt "$padding" "${PRETTY_PROMPT[@]}"
    _reload_history
    _pre_newline
}

PROMPT_COMMAND=_prompt