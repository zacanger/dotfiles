# fork repos
# needs `hub(1)`

hf() {
  if [ "$#" -ne 1 ] ; then
    echo "usage: fork author/repo"
    return 0
  fi

  # you'll need to export GH_FORKS_DIR=somewhere to have this line work
  # cd $GH_FORKS_DIR

  git clone https://github.com/${1}.git

  cd $(echo $1 | sed 's/.*\///')

  hub fork
}

