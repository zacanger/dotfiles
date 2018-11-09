#!/usr/bin/env bash

script=$1
lang=${2:-bash}

printf "#!/usr/bin/env $lang\n\n\n" > "$script"
chmod a+x "$script"

${EDITOR:-vim} -c ':3' "$script"
