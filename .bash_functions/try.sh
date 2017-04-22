try() {
  [[ $- = *e* ]]; SAVED_OPT_E=$?
  set +e
}
