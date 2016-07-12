//usr/local/bin/go run $0 $@; exit $?

package main

import (
  "log"
  "net/http"
  "os"
)

func main() {
  port := os.Getenv("PORT")
  if port == "" {
    port = "3000"
  }
  http.Handle("/", http.FileServer(http.Dir("./")))
  log.Println("Server started: http://localhost:" + port)
  log.Fatal(http.ListenAndServe(":"+port, nil))
}

