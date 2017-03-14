const { writeFileSync } = require('fs')
const generateHangul = () => {
  let string = ''
  for (let s = '가'.charCodeAt(0); s <= '힣'.charCodeAt(0); s++) {
    string += (String.fromCharCode(s) + '\n')
  }
  return string
}
writeFileSync('hangul.md', generateHangul(), 'utf8')
