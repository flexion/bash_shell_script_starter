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
SCRIPT_PATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P)"

## @var DEFAULT_WORD
## @brief default value for the 'word' CLI parameter
declare -i DEFAULT_WORD
# shellcheck disable=SC2034
DEFAULT_WORD="hello"



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
  for ((i=FRAMES - 2; i >= 0; i--)); do
    printf "  File \"%s\", line %s, in %s\n" "${BASH_SOURCE[i + 1]}" "${BASH_LINENO[i]}" "${FUNCNAME[i + 1]}"
    # Grab the source code of the line
    sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i + 1]}"
  done
  exit 1
}

trap die ERR


## @par Example
## @code
## # set values from their defaults
## word="${DEFAULT_WORD}"
##
## # process long options
## for arg in "$@" ; do
##   shift
##   case "$arg" in
##     '--word') set -- "$@" "-w" ;;
##     '--help') set -- "$@" "-h" ;;
##     *)        set -- "$@" "$arg" ;;
##   esac
## done
##
## # process short options
## OPTIND=1
## while getopts "w:h" opt ; do
##   case "$opt" in
##     'w') word="$OPTARG" ;;
##     'h') display_usage ; exit 0 ;;
##     *) echo "Invalid option" ; display_usage ; exit 1 ;;
##   esac
## done
##
## shift "$((OPTIND - 1))
##
## # Process positional arguments
## for file in "$@" ; do
##   printf "%s" "$file"
## done
## @endcode




[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@"

