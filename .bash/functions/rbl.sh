rbl() {
  c=$1
  [[ -z "$c" ]] && c=2
  git rebase -i HEAD~$c
}
