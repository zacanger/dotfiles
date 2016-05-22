grepinfind() {
  find . -name "*$1*" -exec grep -iH "$2" {} \;
}

