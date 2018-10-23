_node_complete() {
  local cur_word options
  cur_word="${COMP_WORDS[COMP_CWORD]}"
  if [[ "${cur_word}" == -* ]] ; then
    COMPREPLY=( $(compgen -W '--no-deprecation --preserve-symlinks --no-force-async-hooks-checks --eval --inspect --debug-brk [ssl_openssl_cert_store] --expose-internals --trace-warnings --debug [has_eval_string] --use-bundled-ca --use-openssl-ca --trace-event-file-pattern --expose_http2 --trace-event-categories --zero-fill-buffers --check --security-reverts --tls-cipher-list --experimental-vm-modules --v8-pool-size --abort-on-uncaught-exception --track-heap-objects --completion-bash --throw-deprecation --perf-prof --experimental-modules --title --v8-options --loader --max-old-space-size --help --print --inspect-brk-node --trace-deprecation --preserve-symlinks-main --experimental-repl-await --trace-sync-io --redirect-warnings --no-warnings --prof-process --inspect-brk --openssl-config --napi-modules --inspect-port --pending-deprecation --stack-trace-limit --perf-basic-prof --experimental-worker --icu-data-dir --require --version --expose-http2 --interactive --inspect-brk= --debug= --debug-brk= -p -r --print <arg> -c --inspect= -e --inspect-brk-node= --prof-process -pe --trace-events-enabled -v -i --debug-port -h' -- "${cur_word}") )
    return 0
  else
    COMPREPLY=( $(compgen -f "${cur_word}") )
    return 0
  fi
}
complete -F _node_complete node node_g