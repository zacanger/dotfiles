# Usage: npmbin
# prepends $(npm bin) to $PATH
# deactivate to unset

deactivate() {
  if [ -n "$_OLD_PATH" ] ; then
    PATH="$_OLD_PATH"
    export PATH
    unset _OLD_PATH
  fi

  if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r 2>/dev/null
  fi

  unset NODE_MODULE_BIN
  if [ ! "$1" = "nondestructive" ] ; then
    unset -f deactivate
  fi
}

npmbin() {
  deactivate nondestructive

  NODE_MODULE_BIN=$(npm bin)
  export NODE_MODULE_BIN

  _OLD_PATH="$PATH"
  PATH="$NODE_MODULE_BIN:$PATH"
  export PATH

  if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r 2>/dev/null
  fi
}
