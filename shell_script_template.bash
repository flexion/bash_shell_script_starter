#!/usr/bin/env bash

## @file shell_script_template.bash
## @brief a quick sample script template
## @details
## This template gives us a few nice things to start with:
##
## 1. some Doxygen-style comments to start things off
## 2. flags to protect us from undefined variables and failed commands
## 3. a `SCRIPT_PATH` variable so we can reference where the script lives
## 4. an error trap that prints the line where an error happens
## 5. a stack dump when errors do happen
## 6. a wrapper to allow us to source this script as if it was a library
## 7. CLI parameter handling
## 8. automagic help / usage generation
## @author Wes Dean

set -euo pipefail

## @var SCRIPT_PATH
## @brief path to where the script lives
declare SCRIPT_PATH
# shellcheck disable=SC2034
SCRIPT_PATH="${SCRIPT_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)}"

## @var LIBRARY_PATH
## @brief location where libraries to be included reside
declare LIBRARY_PATH
LIBRARY_PATH="${LIBRARY_PATH:-${SCRIPT_PATH}/lib/}"

## @var DEFAULT_WORD
## @brief default value for the 'word' CLI parameter
declare DEFAULT_WORD
DEFAULT_WORD="${DEFAULT_WORD:-bird}"

## @fn die
## @brief receive a trapped error and display helpful debugging details
## @details
## When called -- presumably by a trap -- die() will provide details
## about what happened, including the filename, the line in the source
## where it happened, and a stack dump showing how we got there.  It
## will then exit with a result code of 1 (failure)
## @retval 1 always returns failure
## @par Example
## @code
## trap die ERR
## @endcode
die() {
  printf "ERROR %s in %s AT LINE %s\n" "$?" "${BASH_SOURCE[0]}" "${BASH_LINENO[0]}" 1>&2

  local i=0
  local FRAMES=${#BASH_LINENO[@]}

  # FRAMES-2 skips main, the last one in arrays
  for ((i = FRAMES - 2; i >= 0; i--)); do
    printf "  File \"%s\", line %s, in %s\n" "${BASH_SOURCE[i + 1]}" "${BASH_LINENO[i]}" "${FUNCNAME[i + 1]}"
    # Grab the source code of the line
    sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i + 1]}"
  done
  exit 1
}

## @fn display_usage
## @brief display some auto-generated usage information
## @details
## This will take two passes over the script -- one to generate
## an overview based on everything between the @file tag and the
## first blank line and another to scan through getopts options
## to extract some hints about how to use the tool.
## @retval 0 if the extraction was successful
## @retval 1 if there was a problem running the extraction
## @par Example
## @code
## for arg in "$@" ; do
##   shift
##   case "$arg" in
##     '--word') set -- "$@" "-w" ;;   ##- see -w
##     '--help') set -- "$@" "-h" ;;   ##- see -h
##     *)        set -- "$@" "$arg" ;;
##   esac
## done
##
## # process short options
## OPTIND=1
###
##
## while getopts "w:h" option ; do
##   case "$option" in
##     w ) word="$OPTARG" ;; ##- set the word value
##     h ) display_usage ; exit 0 ;;
##     * ) printf "Invalid option '%s'" "$option" 2>&1 ; display_usage 1>&2 ; exit 1 ;;
##   esac
## done
## @endcode
display_usage() {
  local overview
  overview="$(sed -Ene '
  /^[[:space:]]*##[[:space:]]*@file/,${/^[[:space:]]*$/q}
  s/[[:space:]]*@(author|copyright|version|)/\1:/
  s/[[:space:]]*@(note|remarks?|since|test|todo||version|warning)/\1:\n/
  s/[[:space:]]*@(pre|post)/\1 condition:\n/
  s/^[[:space:]]*##([[:space:]]*@[^[[:space:]]*[[:space:]]*)*//p' < "$0")"

  local usage
  usage="$(
    ( 
      sed -Ene "s/^[[:space:]]*(['\"])([[:alnum:]]*)\1[[:space:]]*\).*##-[[:space:]]*(.*)/\-\2\t\t: \3/p" < "$0"
      sed -Ene "s/^[[:space:]]*(['\"])([-[:alnum:]]*)*\1[[:space:]]*\)[[:space:]]*set[[:space:]]*--[[:space:]]*(['\"])[@$]*\3[[:space:]]*(['\"])(-[[:alnum:]])\4.*##-[[:space:]]*(.*)/\2\t\t: \6/p" < "$0"
    ) | sort --ignore-case
  )"

  if [ -n "$overview" ]; then
    printf "Overview\n%s\n" "$overview"
  fi

  if [ -n "$usage" ]; then
    printf "\nUsage:\n%s\n" "$usage"
  fi
}

###
### If there is a library directory (lib/) relative to the
### script's location by default), then attempt to source
### the *.bash files located there.
###

if [ -n "${LIBRARY_PATH}" ] \
                            && [ -d "${LIBRARY_PATH}" ]; then
  for library in "${LIBRARY_PATH}"*.bash; do
    if [ -e "${library}" ]; then
      # shellcheck disable=SC1090
      . "${library}"
    fi
  done
fi

## @fn main()
## @brief This is the main program loop.
## @details
## This is where the logic for the program lives; it's
## called when the script is run as a script (i.e., not
## when it's sourced or included).
main() {

  trap die ERR

  ###
  ### set values from their defaults here
  ###

  word="${DEFAULT_WORD}"

  ###
  ### process long options here
  ###

  for arg in "$@"; do
    shift
    case "$arg" in
      '--word') set -- "$@" "-w" ;; ##- see -w
      '--help') set -- "$@" "-h" ;; ##- see -h
      *) set -- "$@" "$arg" ;;
    esac
  done

  ###
  ### process short options here
  ###

  OPTIND=1
  while getopts "w:h" opt; do
    case "$opt" in
      'w') word="$OPTARG" ;; ##- set the word to be processed
      'h')
        display_usage
        exit 0
        ;; ##- view the help documentation
      *)
        printf "Invalid option '%s'" "$opt" 1>&2
        display_usage 1>&2
        exit 1
        ;;
    esac
  done

  shift "$((OPTIND - 1))"

  ###
  ### process positional arguments
  ###

  for file in "$@"; do
    printf "received argument: '%s'\n" "$file"
  done

  ###
  ### program logic goes here
  ###

  printf "%s %s %s the %s is the word\n" "$word" "$word" "$word" "$word"

}

# if we're not being sourced and there's a function named `main`, run it
[[ "$0" == "${BASH_SOURCE[0]}" ]] && [ "$(type -t "main")" = "function" ] && main "$@"
