#!/usr/bin/env bash

for i; do
  printf "#!/usr/bin/env bash\n\n\n" > "$i"
  chmod a+x "$i"
done

${EDITOR:-vim} -c ':3' "$@"
