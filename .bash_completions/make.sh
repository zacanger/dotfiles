_make() {
  # Find a legible Makefile according to the POSIX spec (look for "makefile"
  # first, then "Makefile"). You may want to add "GNU-makefile" after this.
  local mf
  for mf in makefile Makefile '' ; do
    [[ -f $mf ]] && break
  done
  [[ -n $mf ]] || return 1

  # Iterate through the Makefile, line by line
  local line
  while IFS= read -r line ; do
    case $line in

      # We're looking for targets but not variable assignments
      \#*) ;;
        $'\t'*) ;;
        *:=*) ;;
        *:*)

          # Break the target up with space delimiters
          local -a targets
          IFS=' ' read -rd '' -a targets < \
            <(printf '%s\0' "${line%%:*}")

          # Iterate through the targets and add suitable ones
          local target
          for target in "${targets[@]}" ; do
            case $target in

              # Don't complete special targets beginning with a
              # period
              .*) ;;

              # Don't complete targets with names that have
              # characters outside of the POSIX spec (plus slashes)
              *[^[:word:]./-]*) ;;

              # Add targets that match what we're completing
              ${COMP_WORDS[COMP_CWORD]}*)
              COMPREPLY[${#COMPREPLY[@]}]=$target
              ;;
          esac
        done
        ;;
    esac
  done < "$mf"
}

# bashdefault requires Bash >=3.0
if ((BASH_VERSINFO[0] >= 3)) ; then
  complete -F _make -o bashdefault -o default make
else
  complete -F _make -o default make
fi
