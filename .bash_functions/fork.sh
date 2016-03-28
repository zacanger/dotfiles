fork() {
  if [ "$#" -ne 1 ] ; then
    echo "usage: fork author/repo"
  fi

  # you'll need to export GH_FORKS_DIR=somewhere to have this line work
  # cd $GH_FORKS_DIR

  git clone https://github.com/${1}.git

  cd $(echo $1 | sed 's/.*\///')

  hub fork
}

