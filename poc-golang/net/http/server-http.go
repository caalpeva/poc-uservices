package main

import (
  "net/http"
)

// curl -is http://localhost:8000

func main() {
  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hola Mundo"))
  })
  http.ListenAndServe(":8000", nil)
}
