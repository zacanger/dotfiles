snow() {
  for ((I=0; J=--I; 1))
  do
    clear
    for ((D=LINES; S=++J**3%COLUMNS,--D; 1))
    do
      printf %*s*\\n $S
    done
    sleep 0.1
  done
}
