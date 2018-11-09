#!/usr/bin/env bash

for i; do
  touch "$i"
  chmod a+x "$i"
  printf "#!/usr/bin/env bash\n\n\n" > "$i"
done

${EDITOR:-vim} -c ':3' "$@"
