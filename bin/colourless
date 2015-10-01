#!/bin/sh
case "$1" in
    *.awk|*.groff|*.java|*.js|*.m4|*.php|*.pl|*.pm|*.pod|*.sh|\
    *.ad[asb]|*.asm|*.inc|*.[ch]|*.[ch]pp|*.[ch]xx|*.cc|*.hh|\
    *.lsp|*.l|*.pas|*.p|*.xml|*.xps|*.xsl|*.axp|*.ppd|*.pov|\
    *.diff|*.patch|*.py|*.rb|*.sql|*.ebuild|*.eclass)
        pygmentize -f 256 "$1";;
    .bashrc|.bash_aliases|.bash_environment|*.zshrc|*.zshenv|*.zsh_history)
        pygmentize -f 256 -l sh "$1"
        ;;
    *)
        pygmentize -f 256 -g "$1"
esac

exit 0

