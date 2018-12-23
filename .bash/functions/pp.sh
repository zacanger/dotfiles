pp() {
  git push --follow-tags && npm publish --otp=$1
}
