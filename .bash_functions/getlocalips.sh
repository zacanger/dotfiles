getlocalips() {
  while read A || [ "${A}" ]; do
    case "${A}" in
      [0-9]*)
        echo "${A%% *}"
        ;;
    esac
  done </proc/net/arp
}
