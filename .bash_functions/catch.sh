catch() {
  export ex_code=$?
  (( $SAVED_OPT_E )) && set +e
  return $ex_code
}
