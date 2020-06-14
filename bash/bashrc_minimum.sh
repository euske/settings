# -*- shell-script -*-
##
##  Minimum .bashrc for euske
##

# Do nothing if not interactive.
[[ -z "$PS1" ]] && return

# Shell options.
IGNOREEOF=10
HISTSIZE=50000
HISTFILESIZE=50000
#TMOUT=600  # auto-logout
umask 022
ulimit -c 0
unset MAIL
unset command_not_found_handle
shopt -u sourcepath    # Do not use the PATH for source command.
shopt -s histappend    # Always append to the history.
shopt -s histverify    # Always verify the history expansion.
shopt -s histreedit    # Allow reediting a failed expansion.
shopt -s checkwinsize  # Automatically set LINES and COLUMNS.
shopt -u hostcomplete  # Do not attempt to complete hostnames.
shopt -s no_empty_cmd_completion  # Do not attempt to complete an empty line.

# Environment variables.
unset LANG
export PAGER=less
export EDITOR=vi
export LESS='-F -R -X -K -i -P ?f%f:(stdin).  ?lb%lb?L/%L..  [?eEOF:?pb%pb\%..]'
export RSYNC_RSH=ssh
export CVS_RSH=ssh

# Terminal settings.
#eval `SHELL=sh tset -sQI`
#stty sane start ^- stop ^-
stty start ^- stop ^-

# Prompt settings.
function prompt_cmd {
    # Show the exit code of the last command.
    local s=$?
    if [[ $s -eq 0 ]]; then return; fi
    echo "exit $s"
}
PROMPT_COMMAND=prompt_cmd
PS1="\t $HOSTNAME\w[\!]\$ "

# Convenient functions.
function .. { cd ..; }
function ../ { cd ..; }
function tmp { cd ~/tmp; }
function ls { command ls -Fb "$@"; }
function ll { command ls -Fl "$@"; }
function la { command ls -Fla "$@"; }
function c { command cat "$@"; }
function h { command head "$@"; }
function t { command tail "$@"; }
function T { command tail -f "$@"; }
function j { jobs -l; }
function rmi { command rm -i "$@"; }
function mvi { command mv -i "$@"; }
function cpi { command cp -i "$@"; }
# g, r, G: grep.
function g { LC_CTYPE=C command grep -i "$@"; }
function r { LC_CTYPE=C command grep -ir "$@"; }
function G { LC_CTYPE=C command grep "$@"; }
# hd: hex dump.
function hd {
    od -Ax -tx1z -v "$@";
}
# xargsn: properly handle filenames with spaces.
function xargsn {
    xargs -d '\n' "$@";
}
# l: less for a file, ls for a directory.
function l {
    if [ $# -eq 0 ]; then
        ${PAGER:-less}
    elif [ -d "$1" ]; then
        ls -F "$@"
    else
        ${PAGER:-less} "$@"
    fi
}
# ff: find with some filters.
function ff {
    local path=${1:-.}
    shift
    find "$path" \
         '(' -name '.?*' -o -name CVS -o -name tmp ')' -prune -false -o -type f "$@"
}
# f: find files by name (case insensitive)
function f {
    if [ ! "$1" ]; then
        echo 'usage: f pattern [dir ...]'
    else
        n="*$1*"; shift; find . "$@" -iname "$n"
    fi
}
# F: find files by name (case sensitive)
function F {
    if [ ! "$1" ]; then
        echo 'usage: F Pattern [dir ...]'
    else
        n="*$1*"; shift; find . "$@" -name "$n"
    fi
}
# listcodes: enumerate source codes.
function listcodes {
    ff "${1:-.}" '(' \
         -name '*.c' -o -name '*.cc' -o -name '*.C' -o -name '*.cpp' -o \
         -name '*.h' -o -name '*.H' -o -name '*.hpp' -o \
         -name '*.sh' -o -name '*.rc' -o -name '*.py' -o -name '*.el' -o \
         -name '*.java' -o -name '*.jsp' -o -name '*.cs' -o \
         -name '*.as' -o -name '*.js' -o -name '*.ts' \
         ')';
}
# listtexts: enumerate text files.
function listtexts {
    ff "${1:-.}" '(' \
         -name '*.txt' -o -name '*.md' -o \
         -name '*.html' -o -name '*.htm' -o -name '*.css' -o \
         -name '*.xml' -o -name '*.svg' -o \
         -name '*.tex' -o -name '*.texi' \
         ')';
}
# gg, GG: grep all the source codes.
function gg { listcodes | xargsn grep -i "$@"; }
function GG { listcodes | xargsn grep "$@"; }
# gt: grep all the text files.
function gt { listtexts | xargsn grep -i "$@"; }

# Aliases.
unalias -a
alias 644='chmod 644' # cannot be a function (invalid identifier)
alias 755='chmod 755' # cannot be a function (invalid identifier)

# Completions.
complete -d cd
complete -c man
complete -v unset
