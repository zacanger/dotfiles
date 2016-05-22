//usr/bin/go run $0 $@; exit $?

package main

import (
  "fmt"
)

func main() {
  for i := 1; i <= 100; i++ {

    var text string

    if i % 3 == 0 {
      text += "Fizz"
    }

    if i % 5 == 0 {
      text += "Buzz"
    }

    if text == "" {
      fmt.Println(i)
    } else {
      fmt.Println(text)
    }

  }
}

