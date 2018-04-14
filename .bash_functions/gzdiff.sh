# Compare original and gzipped file size
gzdiff() {
  local origsize
  origsize=$(wc -c < "$1")
  local gzipsize
  gzipsize=$(gzip -c "$1" | wc -c)
  local ratio
  ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}
