//usr/local/bin/go run $0 $@; exit $?

package main

import (
  "log"
  "net/http"
  "html/template"
)

func main() {
  http.HandleFunc("/", root)
  log.Println("Listening...")
  err := http.ListenAndServe(":8080", nil)
  if err != nil {
    log.Fatal("ListenAndServe: ", err)
  }
}

func root(w http.ResponseWriter, r *http.Request) {
  t, _ := template.ParseFiles("index.html")
  t.Execute(w, nil)
}