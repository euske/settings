#!/bin/sh -
#
# To use this filter with less, define LESSOPEN:
# export LESSOPEN="|/usr/bin/lesspipe.sh %s"

lesspipe() {
  case "$1" in
  *.tar) tar tvvf "$1" ;;
  *.tgz|*.tar.gz|*.tar.[zZ]) tar tzvvf "$1" ;;
  *.tar.bz2|*.tbz2) tar tjvvf "$1" ;;
  *.[zZ]|*.gz) gzip -dc -- "$1" ;;
  *.bz2) bzip2 -dc -- "$1" ;;
  *.ZIP|*.JAR|*.zip|*.jar) zipinfo -- "$1" ;;
  *.rpm) rpm -qpivl -- "$1" ;;
  *.cpi|*.cpio) cpio -itv < "$1" ;;
  *.dylib|*.so) nm "$1" ;;
  *.cdb) cdb -m -d "$1" ;;
  *.lzh) lha l "$1" ;;
  *.7z) 7zr l "$1" ;;
  *.rar) unrar l "$1" ;;
  *.iso) isoinfo -l -R -i "$1" ;;
  esac
}

lesspipe "$1" 2> /dev/null
