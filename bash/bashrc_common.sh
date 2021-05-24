# -*- shell-script -*-
##
##  Extended .bashrc for euske
##

# Do nothing if not interactive.
[[ -z "$PS1" ]] && return

# PATH
PATH=~/bin:~/bin/python:$PATH
PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin

# Shell options (overrided).
HISTSIZE=${HISTSIZE:-100000}
HISTFILESIZE=${HISTFILESIZE:-100000}

# Environment variables.
if [ -x /usr/bin/vim ]; then
    export EDITOR=vim
fi
if [ -x $HOME/lib/bash/lesspipe.sh ]; then
    export LESSOPEN="| $HOME/lib/bash/lesspipe.sh %s"
fi

export LV="-Is -Ou"
export PYTHONPATH=.:$HOME/lib/python
export PYTHONSTARTUP=$HOME/lib/python/pythonrc.py
export PYTHONIOENCODING=utf-8
export LYNX_CFG=$HOME/lib/rc/lynx.cfg
export LYNX_LSS=$HOME/lib/rc/lynx.lss
export CMAP_PATH=$HOME/lib/python/pdfminer/cmap
export RSYNC_BACKUP_BASE='.old'
export RSYNC_PATTERN
RSYNC_PATTERN='--exclude NOBACKUP/ --exclude INACTIVE/ --exclude LOCAL/ --exclude local/ --exclude tmp/'
RSYNC_PATTERN=$RSYNC_PATTERN' --include *.obj --include *.Z --exclude *.o'

# Terminal settings.
if [ "linux" = "$TERM" ]; then
    echo -en '\e]P0000000' # black
    echo -en '\e]P1ff4500' # orangered
    echo -en '\e]P200ff00' # green
    echo -en '\e]P3ffd700' # gold
    echo -en '\e]P40000ff' # blue
    echo -en '\e]P5ffbbff' # plum1
    echo -en '\e]P687ceeb' # skyblue
    echo -en '\e]P7ffffff' # white
    echo -en '\e]P8222222' # darkgrey
    echo -en '\e]P9982b2b' # red
    echo -en '\e]PA89b83f' # green
    echo -en '\e]PBefef60' # yellow
    echo -en '\e]PC2b4f98' # blue
    echo -en '\e]PD826ab1' # magenta
    echo -en '\e]PEa1cdcd' # cyan
    echo -en '\e]PFdedede' # lightgray
fi

# Prompt settings.
function set_prompt_color {
    case "$1" in
        red*) col=31;;
        green*) col=32;;
        yellow*) col=33;;
        blue*) col=34;;
        pink*) col=35;;
        cyan*) col=36;;
        *) col=1;;
    esac
    PSS="\t $HOSTNAME:\[\e[${col}m\]\W[\!]\$\[\e[m\] "
    PS1="\t $HOSTNAME\[\e[${col}m\]\w[\!]\$\[\e[m\] "
}
function screen_status {
    if [[ "screen" = "$TERM" ]]; then echo -en "\033k$HOSTNAME:$1\033\0134"; fi
}
function show_exit {
    if [[ $1 -eq 0 ]]; then return; fi
    echo -e "\007exit $1"
}
function log_history {
    if [[ "$MYHISTFILE" ]]; then
	echo "`date '+%Y-%m-%d %H:%M:%S'` $HOSTNAME:$$ $PWD ($1) `history 1`" >> $MYHISTFILE
    fi
}
function prompt_cmd {
    local s=$?
    show_exit $s;
    log_history $s;
    screen_status "${PWD##/*/}"
}
function end_history {
    log_history $?;
    if [[ "$MYHISTFILE" ]]; then
	echo "`date '+%Y-%m-%d %H:%M:%S'` $HOSTNAME:$$ $PWD (end)" >> $MYHISTFILE
    fi
}
function start_history {
    if [[ "$MYHISTFILE" ]]; then
        echo "`date '+%Y-%m-%d %H:%M:%S'` $HOSTNAME:$$ $PWD (start)" >> $MYHISTFILE
        trap end_history EXIT
    fi
}

set_prompt_color $HOST_COLOR
start_history
PROMPT_COMMAND=prompt_cmd

# Convenient functions.

# px: swap the short/long prompts.
function px {
    local tmp=$PS1; PS1=$PSS; PSS=$tmp;
}
# i: show or search the local history.
function i {
    if [ "$1" ]; then
        grep -a "$@" $MYHISTFILE
    else
        tail -100 $MYHISTFILE
    fi
}
# tt: run a command with /usr/bin/time
function tt {
    command /usr/bin/time -v "$@";
}
