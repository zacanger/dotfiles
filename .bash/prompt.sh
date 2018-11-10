ESC=$'['
END_ESC=m

NOPRINT='\['
END_NOPRINT='\]'

WRAP="$NOPRINT$ESC"
END_WRAP="$END_ESC$END_NOPRINT"

RESET="${WRAP}0${END_WRAP}"
RESET_BG="${WRAP}49${END_WRAP}"

NORMAL="${WRAP}21${END_WRAP}"
BOLD="${WRAP}1${END_WRAP}"

function __fg_color {
  printf "%s" "${WRAP}38;5;${1}${END_WRAP}"
}

function __bg_color {
  printf "%s" "${WRAP}48;5;${1}${END_WRAP}"
}

BLACK=$(__fg_color 0)
RED=$(__fg_color 1)
GREEN=$(__fg_color 2)
YELLOW=$(__fg_color 3)
BLUE=$(__fg_color 4)
PURPLE=$(__fg_color 5)
CYAN=$(__fg_color 6)
WHITE=$(__fg_color 7)

ALT_BLACK=$(__fg_color 8)
ALT_RED=$(__fg_color 9)
ALT_GREEN=$(__fg_color 10)
ALT_YELLOW=$(__fg_color 11)
ALT_BLUE=$(__fg_color 12)
ALT_PURPLE=$(__fg_color 13)
ALT_CYAN=$(__fg_color 14)
ALT_WHITE=$(__fg_color 15)

BLACK_BG=$(__bg_color 0)
RED_BG=$(__bg_color 1)
GREEN_BG=$(__bg_color 2)
YELLOW_BG=$(__bg_color 3)
BLUE_BG=$(__bg_color 4)
PURPLE_BG=$(__bg_color 5)
CYAN_BG=$(__bg_color 6)
WHITE_BG=$(__bg_color 7)

ALT_BLACK_BG=$(__bg_color 8)
ALT_RED_BG=$(__bg_color 9)
ALT_GREEN_BG=$(__bg_color 10)
ALT_YELLOW_BG=$(__bg_color 11)
ALT_BLUE_BG=$(__bg_color 12)
ALT_PURPLE_BG=$(__bg_color 13)
ALT_CYAN_BG=$(__bg_color 14)
ALT_WHITE_BG=$(__bg_color 15)

function __parse_git_branch() {
  local branch stat

  if branch=$( { git symbolic-ref --quiet HEAD || git rev-parse --short HEAD; } 2>/dev/null ); then
    stat="$(__parse_git_dirty)"
    printf "%s" "${branch##*/}${stat}"
    return
  fi

  return 1
}

function __parse_git_dirty {
  local status dirty untracked ahead newfile renamed deleted bits

  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi

  if [ ! "${bits}" == "" ]; then
    printf "%s" " ${bits}"
  fi
}

function __prompt_ps1 {
  printf "%s" "${NORMAL}\w "

  local stat
  if stat=$(__parse_git_branch); then
    printf "%s" "${stat} "
  fi

  printf "%s" "${RESET_BG}$(__fg_color 241)"
  printf "%s" "${RESET}${RESET_BG}"
}

function __prompt {
  PS1="$(__prompt_ps1)"
}

if [[ ! "$PROMPT_COMMAND" == *__prompt* ]]; then
  case $(tty) in
    /dev/tty[0-9]*)
      ;;
    *)
      PROMPT_COMMAND='__prompt;'$'\n'"$PROMPT_COMMAND" ;;
  esac
fi
