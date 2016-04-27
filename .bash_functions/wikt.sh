wikt() {
  curl -s "http://en.wiktionary.org/w/index.php?action=raw&title=$(echo $@ | sed 's/ /+/g')"
}

