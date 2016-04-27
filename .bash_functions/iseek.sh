# needs npm.im/ipt

iseek() {
  cd $(ls -a -d */ .. | ipt)
  iseek
}

